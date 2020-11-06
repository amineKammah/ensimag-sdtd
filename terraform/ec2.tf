resource "aws_key_pair" "admin" {
   key_name   = "admin"
   public_key = "${file("${var.PATH_TO_PUBLIC_KEY}")}"
 }
 resource "aws_instance" "server1" {
   ami           = "ami-0739f8cdb239fe9ae"
   instance_type = "t2.medium"
   key_name      = "admin"
 }
