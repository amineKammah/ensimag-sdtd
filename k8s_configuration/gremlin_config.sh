curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
sudo apt-get install apt-transport-https --yes
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
helm repo add gremlin https://helm.gremlin.com
kubectl create namespace gremlin
helm install gremlin gremlin/gremlin \
    --namespace gremlin \
    --set gremlin.secret.managed=true \
    --set gremlin.secret.type=secret \
    --set gremlin.secret.teamID=19c22ae5-7f7b-5966-96e7-7ddf31f3e103 \
    --set gremlin.secret.clusterID=K8S_SDTD \
    --set gremlin.secret.teamSecret=93be2785-1971-47ec-be27-85197187ec8a
# LAST DEPLOYED: Thu Jan 21 12:52:09 2021
# NAMESPACE: gremlin
# STATUS: deployed
# REVISION: 1
# TEST SUITE: None