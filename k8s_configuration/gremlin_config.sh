# Run these commands if u want to use gremlin to test scenarios
# remplace the variables above with your acount variables 
helm repo add gremlin https://helm.gremlin.com
kubectl create namespace gremlin
helm install gremlin gremlin/gremlin \
    --namespace gremlin \
    --set gremlin.secret.managed=true \
    --set gremlin.secret.type=secret \
    --set gremlin.secret.teamID=$GREMLIN_TEAM_ID \
    --set gremlin.secret.clusterID=K8S_SDTD \
    --set gremlin.secret.teamSecret=$GREMLIN_TEAM_SECRET