# configure the EC2 instances

# Create the master
resource "aws_instance" "SDTD_instance_master" {
  ami           = lookup(var.amis, var.region)
  instance_type = "t2.medium"
  key_name      = "id_rsa_aws"
  security_groups = [aws_security_group.SDTD_VPC_Security_Group.id]
  #vpc_security_group_ids = [aws_vpc.SDTD_VPC.id]
  subnet_id = aws_subnet.SDTD_VPC_Subnet.id
  iam_instance_profile = "k8s-cluster-iam-master-role"

  tags = {
     Name = "k8s-master-ec2-sdtd"
     "kubernetes.io/cluster/kubernetes" = "owned"
  }
}

# Configure Worker 1

resource "aws_instance" "SDTD_instance_worker_1" {
  ami           = lookup(var.amis, var.region)
  instance_type = "t2.small"
  key_name      = "id_rsa_aws"
  security_groups = [aws_security_group.SDTD_VPC_Security_Group.id]
  #vpc_security_group_ids = [aws_vpc.SDTD_VPC.id]
  subnet_id = aws_subnet.SDTD_VPC_Subnet.id
  iam_instance_profile = "k8s-cluster-iam-worker-role"
  tags = {
     Name = "k8s-worker-1-ec2-sdtd"
     "kubernetes.io/cluster/kubernetes" = "owned"
  }
}

# Configure Worker 2

resource "aws_instance" "SDTD_instance_worker_2" {
  ami           = lookup(var.amis, var.region)
  instance_type = "t2.small"
  key_name      = "id_rsa_aws"
  security_groups = [aws_security_group.SDTD_VPC_Security_Group.id]
  #vpc_security_group_ids = [aws_vpc.SDTD_VPC.id]
  subnet_id = aws_subnet.SDTD_VPC_Subnet.id
  iam_instance_profile = "k8s-cluster-iam-worker-role"

  tags = {
     Name = "k8s-worker-2-ec2-sdtd"
     "kubernetes.io/cluster/kubernetes" = "owned"
  }
}

# to use if the aws key pai doesn't exist
# aws_key_pair
# resource "aws_key_pair" "deployer" {
#   key_name   = "id_rsa_aws"
#   public_key = file(var.PATH_TO_PUBLIC_KEY)
# }
