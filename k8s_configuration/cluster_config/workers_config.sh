#!/bin/bash
# Install kubeadm and Docker
sudo apt update && sudo apt -y upgrade
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo bash -c 'echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list'
sudo apt update
sudo apt install -y docker-ce kubelet kubeadm kubectl
export HOME=/root
# Configure hostname
varHost=$(sudo curl http://169.254.169.254/latest/meta-data/local-hostname)
sudo hostnamectl set-hostname $varHost
# Run kubeadm
sleep 10
git clone https://amineKammah:95ec4f4005cfccdd0dfa2779a2f9c0861f104d94@github.com/amineKammah/ensimag-sdtd.git ~/ensimag-sdtd
#k8s_configuration/aws.yml
cd ~/ensimag-sdtd
sub_pattern="s/#TOKEN#/${local.token}/;s/#MASTER_IP#/${aws_instance.master.private_ip}/;s/#HOSTNAME#/$varHost/"
sed "$sub_pattern" k8s_configuration/node.yml > ~/node_sdtd.yml
cat ~/node_sdtd.yml
sudo kubeadm join --config ~/node_sdtd.yml