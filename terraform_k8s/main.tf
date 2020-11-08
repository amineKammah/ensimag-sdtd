provider "aws" {
  profile = "default"
  region = "us-east-1"
}


module "cluster" {
  source  = "weibeld/kubeadm/aws"
  version = "~> 0.2"
  vpc_id    = var.vpc_id
  subnet_id = var.subnet_id
}


resource "aws_key_pair" "deployer" {
   key_name   = "id_rsa_aws"
   public_key = file(var.PATH_TO_PUBLIC_KEY)
 }
