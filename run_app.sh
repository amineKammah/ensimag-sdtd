# Run Zookeeper and Kafka Service
kubectl create -f messaging_agent/yaml_files/zookeeper-service.yaml
kubectl create -f messaging_agent/yaml_files/zookeeper-cluster.yaml
kubectl create -f messaging_agent/yaml_files/kafka-service.yaml

# Getting service IP
K8S_MASTER=$(
  kubectl get node --selector=node-role.kubernetes.io/master \
  -o jsonpath='{$.items[*].status.addresses[?(@.type=="InternalIP")].address}'
)
KAFKA_SERVER1=$(kubectl describe services kaf1 | grep IP: | awk '{print $2;}')
KAFKA_SERVER2=$(kubectl describe services kaf2 | grep IP: | awk '{print $2;}')
ZK_SERVER1=$(kubectl describe services zoo1 | grep IP: | awk '{print $2;}')
ZK_SERVER2=$(kubectl describe services zoo2 | grep IP: | awk '{print $2;}')
echo "Kafka servers IP: $KAFKA_SERVER1, $KAFKA_SERVER2."
echo "Zookeeper servers IP: $ZK_SERVER1, $ZK_SERVER2."
echo "Kubernetes master IP: $K8S_MASTER."

# Prepare yaml file for kafka deployment
sub_pattern="s/#KAFKA_SERVER1#/$KAFKA_SERVER1/;s/#KAFKA_SERVER2#/$KAFKA_SERVER2/"
sed "$sub_pattern" messaging_agent/yaml_files/kafka-cluster.yaml > /tmp/kafka-cluster.yaml

kubectl create -f /tmp/kafka-cluster.yaml


# Create spark service account
kubectl apply -f data_processing/yaml_files/spark-rbac.yaml

# Prepare yaml file for spark-job
sub_pattern="s/#KAFKA_SERVER1#/$KAFKA_SERVER1/;s/#KAFKA_SERVER2#/$KAFKA_SERVER2/;
             s/#ZK_SERVER1#/$ZK_SERVER1/;s/#ZK_SERVER2#/$ZK_SERVER2/;
             s/#K8S_MASTER#/$K8S_MASTER/"
sed "$sub_pattern" data_processing/yaml_files/spark-job.yaml > /tmp/spark-job.yaml
kubectl create -f /tmp/spark-job.yaml

# Run Demo app
sub_pattern="s/#KAFKA_SERVER1#/$KAFKA_SERVER1/;s/#KAFKA_SERVER2#/$KAFKA_SERVER2/"
sed "$sub_pattern" demo_app/yaml_files/flask-deployment.yaml > /tmp/flask-deployment.yaml
kubectl create -f /tmp/flask-deployment.yaml
kubectl port-forward deployment/demo-app 5001:5001 &