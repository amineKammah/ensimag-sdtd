# Create the Security Group
resource "aws_security_group" "SDTD_VPC_Security_Group" {
  vpc_id       = aws_vpc.SDTD_VPC.id
  name         = "k8s-cluster-sg-sdtd"

  ingress {
   from_port   = 0
   to_port     = 0
   protocol    = "-1"
   cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outgoing traffic to anywhere.
  egress {
   from_port   = 0
   to_port     = 0
   protocol    = "-1"
   cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
   Name = "k8s-cluster-sg-sdtd"
}
} # end resource
