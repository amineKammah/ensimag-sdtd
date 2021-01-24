#------------------------------------------------------------------------------#
# Common local values
#------------------------------------------------------------------------------#
terraform {
  required_version = ">= 0.12"
}

resource "random_pet" "cluster_name" {}

locals {
  cluster_name = var.cluster_name != null ? var.cluster_name : random_pet.cluster_name.id
}


#------------------------------------------------------------------------------#
# Bootstrap token for kubeadm
#------------------------------------------------------------------------------#

# Generate bootstrap token
# See https://kubernetes.io/docs/reference/access-authn-authz/bootstrap-tokens/
resource "random_string" "token_id" {
  length  = 6
  special = false
  upper   = false
}

resource "random_string" "token_secret" {
  length  = 16
  special = false
  upper   = false
}

locals {
  token = "${random_string.token_id.result}.${random_string.token_secret.result}"
}

#----------------------------------------------------------------------#
# Configure the EC2 instances
#----------------------------------------------------------------------#


#----------------------------------------------------------------------#
# Configure the Master node
#----------------------------------------------------------------------#

resource "aws_instance" "master" {
  ami           = lookup(var.amis, var.region)
  instance_type = var.master_instance_type
  key_name      = "id_rsa_sdtd"
  security_groups = [aws_security_group.SDTD_VPC_Security_Group.id]
  subnet_id = aws_subnet.SDTD_VPC_Subnet.id
  iam_instance_profile = "k8s-cluster-iam-master-profile"
  tags = {
     Name = "k8s-master-ec2-sdtd"
     "kubernetes.io/cluster/kubernetes" = "owned"
  }
  user_data = <<-EOF
  #!/bin/bash
  # Install kubeadm and Docker
  apt update && sudo apt -y upgrade
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
  bash -c 'echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list'
  apt update
  apt install -y docker-ce kubelet kubeadm kubectl
  # Configure hostname
  varHost=$( curl http://169.254.169.254/latest/meta-data/local-hostname)
  hostnamectl set-hostname $varHost
  git clone https://github.com/amineKammah/ensimag-sdtd.git ~/ensimag-sdtd
  #k8s_configuration/aws.yml
  cd ~/ensimag-sdtd
  varMasterIp=$(hostname -I)
  varMaster=$(echo $varMasterIp | cut -d' ' -f1)
  sub_pattern="s/#TOKEN#/${local.token}/;s/#MASTER_IP#/$varMaster/"
  sed "$sub_pattern" k8s_configuration/aws.yml > ~/aws_sdtd.yml
  cat ~/aws_sdtd.yml
  export HOME=/root
  #kubeadm init --config ~/aws_sdtd.yml --v=5 --ignore-preflight-errors="ERROR SystemVerification"
  kubeadm init --config ~/aws_sdtd.yml
  # Prepare kubeconfig file for download to local machine
  mkdir -p /root/.kube
  cp -i /etc/kubernetes/admin.conf /root/.kube/config
  chown 0:0 /root/.kube/config
  # Make the master ready
  chmod +x run_app.sh
  chmod +x destroy_app.sh
  chmod +x run_kubeadm.sh
  kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
  sleep 30
  ./run_app.sh
  EOF
}


#----------------------------------------------------------------------#
# Configure the Worker nodes
#----------------------------------------------------------------------#


resource "aws_instance" "workers" {
  count         = var.num_workers
  ami           = lookup(var.amis, var.region)
  instance_type = var.worker_instance_type
  key_name      = "id_rsa_sdtd"
  security_groups = [aws_security_group.SDTD_VPC_Security_Group.id]
  subnet_id = aws_subnet.SDTD_VPC_Subnet.id
  iam_instance_profile = "k8s-cluster-iam-worker-profile"

  tags = {
     Name = "k8s-worker-${count.index}-sdtd"
     "kubernetes.io/cluster/kubernetes" = "owned"
  }
  user_data = <<-EOF
  #!/bin/bash
  # Install kubeadm and Docker
  sudo apt update && sudo apt -y upgrade
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
  sudo bash -c 'echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list'
  sudo apt update
  sudo apt install -y docker-ce kubelet kubeadm kubectl
  export HOME=/root
  # Configure hostname
  varHost=$(sudo curl http://169.254.169.254/latest/meta-data/local-hostname)
  sudo hostnamectl set-hostname $varHost
  # Run kubeadm
  sleep 10
  git clone https://github.com/amineKammah/ensimag-sdtd.git ~/ensimag-sdtd
  #k8s_configuration/aws.yml
  cd ~/ensimag-sdtd
  sub_pattern="s/#TOKEN#/${local.token}/;s/#MASTER_IP#/${aws_instance.master.private_ip}/;s/#HOSTNAME#/$varHost/"
  sed "$sub_pattern" k8s_configuration/node.yml > ~/node_sdtd.yml
  cat ~/node_sdtd.yml
  sudo kubeadm join --config ~/node_sdtd.yml
  cd k8s_configuration/
  chmod +x gremlin_config.sh
  ./gremlin_config.sh
  EOF
}

#----------------------------------------------------------------------#
# Configure the aws key pair
#----------------------------------------------------------------------#

# aws_key_pair
resource "aws_key_pair" "deployer" {
  key_name   = "id_rsa_sdtd"
  public_key = file(var.public_key_file)
}
#---------------------------------------------------------------------------
