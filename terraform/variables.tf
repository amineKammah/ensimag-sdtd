# variable "AWS_ACCESS_KEY" {}
# variable "AWS_SECRET_KEY" {}
variable "AWS_REGION" {
  default = "us-east-1"
}
variable "AMIS" {
  type = map
  default = {
    eu-west-3  = "ami-0081c55264b4f42a1"
    eu-south-1 = "ami-0ae82b98c54a93226"
    us-east-1 = "ami-0739f8cdb239fe9ae"
  }
}
# ici mettez le path vers vos clé
variable "PATH_TO_PRIVATE_KEY" {
  default = "ssh-keys/id_rsa_aws"
}
variable "PATH_TO_PUBLIC_KEY" {
  default = "ssh-keys/id_rsa_aws.pub"
}
variable "AWS_INSTANCE_USERNAME" {
  default = "ubuntu"
}
