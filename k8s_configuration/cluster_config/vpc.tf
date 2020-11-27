# vpc.tf
# Create VPC/Subnet/Security Group/Network ACL

# Configure the AWS Provider
provider "aws" {
  profile = "default"
  region = var.region
}

# Create the VPC
resource "aws_vpc" "SDTD_VPC" {
  cidr_block           = var.vpcCIDRblock
  instance_tenancy     = var.instanceTenancy
  enable_dns_support   = var.dnsSupport
  enable_dns_hostnames = var.dnsHostNames

tags = {
   Name = "k8s-cluster-vpc-sdtd"
  "kubernetes.io/cluster/kubernetes" = "owned"
}

} # end resource

# Create the Subnet
resource "aws_subnet" "SDTD_VPC_Subnet" {
  vpc_id                  = aws_vpc.SDTD_VPC.id
  cidr_block              = var.subnetCIDRblock
  map_public_ip_on_launch = var.mapPublicIP
  availability_zone       = var.availabilityZone
tags = {
  Name = "k8s-cluster-net-SDTD"
 "kubernetes.io/cluster/kubernetes" = "owned"
}
} # end resource

# Create the internet geteway
resource "aws_internet_gateway" "SDTD_igw" {
 vpc_id = aws_vpc.SDTD_VPC.id
 tags = {
        Name = "k8s-cluster-igw-sdtd"
        "kubernetes.io/cluster/kubernetes" = "owned"
}
} # end resource

# Configure The Route Table
resource "aws_route_table" "SDTD_rtb" {

 vpc_id =aws_vpc.SDTD_VPC.id

 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.SDTD_igw.id
 }
 tags = {
        Name = "k8s-cluster-igw-rtb"
        "kubernetes.io/cluster/kubernetes" = "owned"
}
} # end resource


# Associate the Route Table with the Subnet
resource "aws_route_table_association" "SCTD_VPC_association" {
  subnet_id      = aws_subnet.SDTD_VPC_Subnet.id
  route_table_id = aws_route_table.SDTD_rtb.id
} # end resource
