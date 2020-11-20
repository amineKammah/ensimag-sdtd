#!/bin/sh
sudo su -
apt update && apt -y upgrade && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list && apt update && apt install -y docker-ce kubelet kubeadm kubectl
curl http://169.254.169.254/latest/meta-data/local-hostname | hostnamectl set-hostname
