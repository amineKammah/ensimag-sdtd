sudo su -
ufw disable
swapoff -a; sed -i '/swap/d' /etc/fstab
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

apt-get update
apt install default-jdk scala git -y
wget https://downloads.apache.org/spark/spark-3.0.1/spark-3.0.1-bin-hadoop2.7.tgz
tar xvf spark-3.0.1-bin-hadoop2.7.tgz
mv spark-3.0.1-bin-hadoop2.7 /opt/spark
echo "export SPARK_HOME=/opt/spark" >> ~/.profile
echo "export PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin" >> ~/.profile
echo "export PYSPARK_PYTHON=/usr/bin/python3" >> ~/.profile
source ~/.profile
apt-get install docker.io
systemctl enable docker
systemctl status docker
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
apt-get install kubeadm kubelet kubectl
apt-mark hold kubeadm kubelet kubectl
apt install python3-pip
apt install python-is-python3
pip3 install pytesseract Pillow


curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
sudo apt-get install apt-transport-https --yes
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator
helm install incubator/sparkoperator --generate-name --namespace spark-operator --set sparkJobNamespace/=default

kubeadm init
hostnamectl set-hostname master-node
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://docs.projectcalico.org/v3.14/manifests/calico.yaml
kubeadm token create --print-join-command

kubeadm join 172.31.75.160:6443 --token 1dgaln.wp4hayxbzvcxzcbi     --discovery-token-ca-cert-hash sha256:f07c800f010b0ca946dcb8dd604d2a5da8f490b4e63b68ce7fd87bef80bb4d48

git clone https://amineKammah@github.com/amineKammah/ensimag-sdtd.git
95ec4f4005cfccdd0dfa2779a2f9c0861f104d94


bin/spark-submit \
  --deploy-mode cluster \
  --class org.apache.spark.examples.SparkPi \
  --master k8s://https://https://172-31-68-107:6443 \
  --kubernetes-namespace default \
  --conf spark.executor.instances=5 \
  --conf spark.app.name=spark-pi \
  --conf spark.kubernetes.driver.docker.image=kubespark/spark-driver:v2.2.0-kubernetes-0.5.0 \
  --conf spark.kubernetes.executor.docker.image=kubespark/spark-executor:v2.2.0-kubernetes-0.5.0 \
  local:///opt/spark/examples/jars/spark-examples_2.11-2.2.0-k8s-0.5.0.jar

./bin/spark-submit \
    --master k8s://https://172.31.45.129:6443\
    --deploy-mode cluster \
    --name spark-py \
    --conf spark.executor.instances=1 \
    --conf spark.kubernetes.container.image=kammahm/spark-py \
    local:///ensimag-sdtd/data_processing/ocr_service.py


#    --class org.apache.spark.examples.SparkPi \


kubeadm join 172.31.68.154:6443 --token dtwjjm.p9rpkx5oevln8kll \
    --discovery-token-ca-cert-hash sha256:35fb63959fadf9b10264e997689e7758ac3685d738921c0603253abb17ccd4a9


kubeadm init --apiserver-advertise-address=18.207.130.136 --pod-network-cidr=192.168.0.0/16  --ignore-preflight-errors=all















-------------------------------------------
---
apiServer:
  extraArgs:
    cloud-provider: aws
apiServerCertSANs:
- cp.theithollowlab.com
apiServerExtraArgs:
  endpoint-reconciler-type: lease
apiVersion: kubeadm.k8s.io/v1beta1
clusterName: sdtd #your cluster name
controllerManager:
  extraArgs:
    cloud-provider: aws
    configure-cloud-routes: 'false'
kind: ClusterConfiguration
kubernetesVersion: 1.19.3 #your desired k8s version
networking:
  dnsDomain: cluster.local
  podSubnet: 10.0.0.0/24 #your pod subnet matching your CNI config
nodeRegistration:
  kubeletExtraArgs:
    cloud-provider: aws

swapoff -a
sed -i.bak -r 's/(.+ swap .+)/#\1/' /etc/fstab

sudo apt-get update &amp;&amp; sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
apt-get install kubeadm kubelet kubectl
apt-mark hold kubeadm kubelet kubectl


sudo apt install docker.io -y

cat > /etc/docker/daemon.json &lt;&lt;EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

sudo systemctl restart docker
sudo systemctl enable docker
