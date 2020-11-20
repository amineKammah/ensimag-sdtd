# Variables.tf


# key

variable "PATH_TO_PUBLIC_KEY" {
  default = "../ssh-keys/id_rsa_aws.pub"
}

variable "region" {
  default = "us-east-1"
}

# VPC parameters

variable "instanceTenancy" {
    default = "default"
}
variable "dnsSupport" {
    default = true
}
variable "dnsHostNames" {
    default = true
}
variable "vpcCIDRblock" {
    default = "10.0.0.0/16"
}

# Subnet Parameters

variable "availabilityZone" {
     default = "us-east-1a"
}

variable "subnetCIDRblock" {
    default = "10.0.0.0/24"
}

variable "mapPublicIP" {
    default = true
}

# EC2 instance

variable "amis" {
  type = map
  default = {
    eu-west-3  = "ami-0081c55264b4f42a1"
    eu-south-1 = "ami-0ae82b98c54a93226"
    us-east-1 = "ami-0885b1f6bd170450c"
  }
}
