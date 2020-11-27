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
# Elastic IP for master node
#------------------------------------------------------------------------------#

# EIP for master node because it must know its public IP during initialisation
resource "aws_eip" "master" {
  vpc  = true
}

resource "aws_eip_association" "master" {
  allocation_id = aws_eip.master.id
  instance_id   = aws_instance.master.id
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


# Create the master
resource "aws_instance" "master" {
  ami           = lookup(var.amis, var.region)
  instance_type = var.master_instance_type
  key_name      = "id_rsa_sdtd"
  security_groups = [aws_security_group.SDTD_VPC_Security_Group.id]
  subnet_id = aws_subnet.SDTD_VPC_Subnet.id
  iam_instance_profile = "k8s-cluster-iam-master-role"
  #user_data = file("./master_config.sh")
  tags = {
     Name = "k8s-master-ec2-sdtd"
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

  # Configure hostname
  varHost=$(sudo curl http://169.254.169.254/latest/meta-data/local-hostname)
  sudo hostnamectl set-hostname $varHost
  git clone https://amineKammah:95ec4f4005cfccdd0dfa2779a2f9c0861f104d94@github.com/amineKammah/ensimag-sdtd.git ~/ensimag-sdtd
  #k8s_configuration/aws.yml
  cd ~/ensimag-sdtd
  sub_pattern='s/#TOKEN#/${local.token}/;s/#MASTER_IP#/${aws_instance.master.private_ip}/'
  sed "$sub_pattern" k8s_configuration/aws.yml > ~/aws_sdtd.yml

  sudo kubeadm init --config ~/aws_sdtd.yml
  # Prepare kubeconfig file for download to local machine
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
  
  # Make the master ready
  kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
  chmod +x run_app.sh
  sleep 30
  ./run_app.sh
  EOF
}


# Configure Workers

resource "aws_instance" "workers" {
  count         = var.num_workers
  ami           = lookup(var.amis, var.region)
  instance_type = var.worker_instance_type
  key_name      = "id_rsa_sdtd"
  security_groups = [aws_security_group.SDTD_VPC_Security_Group.id]
  subnet_id = aws_subnet.SDTD_VPC_Subnet.id
  iam_instance_profile = "k8s-cluster-iam-worker-role"
  #user_data = file("./workers_config.sh")

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

  # Configure hostname
  varHost=$(sudo curl http://169.254.169.254/latest/meta-data/local-hostname)
  sudo hostnamectl set-hostname $varHost
  # Run kubeadm
  sleep 10
  git clone https://amineKammah:95ec4f4005cfccdd0dfa2779a2f9c0861f104d94@github.com/amineKammah/ensimag-sdtd.git ~/ensimag-sdtd
  #k8s_configuration/aws.yml
  cd ~/ensimag-sdtd
  sub_pattern='s/#TOKEN#/${local.token}/;s/#MASTER_IP#/${aws_instance.master.private_ip}/;s/#HOSTNAME#/$varHost/'
  sed "$sub_pattern" k8s_configuration/node.yml > ~/node_sdtd.yml
  sudo kubeadm join --config ~/node_sdtd.yml
  EOF
}


# to use if the aws key pai doesn't exist
# aws_key_pair
resource "aws_key_pair" "deployer" {
   key_name   = "id_rsa_sdtd"
   public_key = file(var.public_key_file)
}
 #---------------------------------------------------------------------------
