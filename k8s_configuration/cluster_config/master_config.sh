#!/bin/bash
# Install kubeadm and Docker
apt update && sudo apt -y upgrade
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
bash -c 'echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list'
apt update
apt install -y docker-ce kubelet kubeadm kubectl
# Configure hostname
varHost=$( curl http://169.254.169.254/latest/meta-data/local-hostname)
hostnamectl set-hostname $varHost
git clone https://amineKammah:95ec4f4005cfccdd0dfa2779a2f9c0861f104d94@github.com/amineKammah/ensimag-sdtd.git ~/ensimag-sdtd
#k8s_configuration/aws.yml
cd ~/ensimag-sdtd
varMasterIp=$(hostname -I)
varMaster=$(echo $varMasterIp | cut -d' ' -f1)
sub_pattern="s/#TOKEN#/${local.token}/;s/#MASTER_IP#/$varMaster/"
sed "$sub_pattern" k8s_configuration/aws.yml > ~/aws_sdtd.yml
cat ~/aws_sdtd.yml
export HOME=/root
curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
sudo apt-get install apt-transport-https --yes
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
kubeadm init --config ~/aws_sdtd.yml
# Prepare kubeconfig file for download to local machine
mkdir -p /root/.kube
cp -i /etc/kubernetes/admin.conf /root/.kube/config
chown 0:0 /root/.kube/config
# Make the master ready
chmod +x run_app.sh
chmod +x destroy_app.sh
chmod +x run_kubeadm.sh
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
sleep 30
./run_app.sh