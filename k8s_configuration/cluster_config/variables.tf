# Variables.tf


# keys

variable "private_key_file" {
  type        = string
  description = "Filename of the private key of a key pair on your local machine. This key pair will allow to connect to the nodes of the cluster with SSH."
  default     = "../ssh-keys/id_rsa_sdtd"
}

variable "public_key_file" {
  type        = string
  description = "Filename of the public key of a key pair on your local machine. This key pair will allow to connect to the nodes of the cluster with SSH."
  default     = "../ssh-keys/id_rsa_sdtd.pub"
}


variable "cluster_name" {
  type        = string
  description = "**This is an optional variable with a default value of null**. Name for the Kubernetes cluster. This name will be used as the value for the \"terraform-kubeadm:cluster\" tag that is assigned to all created AWS resources. If null, a random name is automatically chosen."
  default     = "SDTD-cluster"
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

  variable "master_instance_type" {
    type        = string
    description = "EC2 instance type for the master node (must have at least 2 CPUs)."
    default     = "t2.medium"
  }

  variable "worker_instance_type" {
    type        = string
    description = "EC2 instance type for the worker nodes."
    default     = "t2.medium"
  }

  variable "num_workers" {
    type        = number
    description = "Number of worker nodes."
    default     = 1
  }
  variable "kubeconfig_dir" {
    type        = string
    description = "Directory on the local machine in which to save the kubeconfig file of the created cluster. The basename of the kubeconfig file will consist of the cluster name followed by \".conf\", for example, \"my-cluster.conf\". The directory may be specified as an absolute or relative path. The directory must exist, otherwise an error occurs. By default, the current working directory is used."
    default     = "."
  }

  variable "kubeconfig_file" {
    type        = string
    description = "**This is an optional variable with a default value of null**. The exact filename as which to save the kubeconfig file of the crated cluster on the local machine. The filename may be specified as an absolute or relative path. The parent directory of the filename must exist, otherwise an error occurs. If a file with the same name already exists, it will be overwritten. If this variable is set to a value other than null, the value of the \"kubeconfig_dir\" variable is ignored."
    default     = null
  }
