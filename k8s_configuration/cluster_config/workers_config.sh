#!/bin/bash
# Install kubeadm and Docker
sudo apt update && sudo apt -y upgrade
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo bash -c 'echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list'
sudo apt update
sudo apt install -y docker-ce kubelet kubeadm kubectl

# Configure hostname
varHost=$(sudo curl http://169.254.169.254/latest/meta-data/local-hostname)
sudo hostnamectl set-hostname $varHost
# Run kubeadm
sleep 100
sudo kubeadm join ${aws_instance.master.private_ip}:6443 \
  --token ${local.token} \
  --discovery-token-unsafe-skip-ca-verification
