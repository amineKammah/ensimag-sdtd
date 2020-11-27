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
sudo kubeadm init \
  --token "${local.token}" \
  --token-ttl 15m \
  --apiserver-cert-extra-sans "${aws_eip.master.public_ip}"
  --pod-network-cidr "10.244.0.0/16" \
  --service-cidr "10.100.0.0/16" \


mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
# Make the master ready
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml