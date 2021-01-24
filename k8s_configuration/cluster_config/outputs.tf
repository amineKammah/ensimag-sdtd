output "public_ip" {
  value       = aws_instance.master.public_ip
  description = "The public IP of the master node"
}
