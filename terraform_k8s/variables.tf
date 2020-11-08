#------------------------------------------------------------------------------#
# Required variables
#------------------------------------------------------------------------------#

variable "vpc_id" {
  type        = string
  description = "ID of an existing VPC in which to create the cluster."
}

variable "subnet_id" {
  type        = string
  description = "ID of an existing subnet in which to create the cluster. The subnet must be in the VPC specified in the \"vpc_id\" variable, otherwise an error occurs."
}


variable "PATH_TO_PUBLIC_KEY" {
  default = "ssh-keys/id_rsa_aws.pub"
}


#------------------------------------------------------------------------------#
# Optional variables
#------------------------------------------------------------------------------#

variable "region" {
  type        = string
  description = "AWS region in which to create the cluster."
  default     = "us-east-1"
}
