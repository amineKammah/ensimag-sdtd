# Ensimag -- Distributed Systems for Data Processing
Implementing and deploying an OCR (Optical Character Recognition) service and its infrastructure using:
- Terraform to automatically create a Kubernetes cluster on AWS EC2 Instances.
- Kubernetes (Using Kubeadm) as an orchestrator for the service.
- Flask/JS to allow interaction with Users.
- Spark/Python for Distributed Data Processing.
- Kafka as a messaging Agent between Flask - Spark - MongoDB.

## Prerequisite
Install Terraform.

## Usage
 - make sure to paste your aws credentials in "~/.aws/credentials"
 - in "./k8s_configuration/cluster_config" run : 
```bash
terraform init
terraform apply -auto-approve
```
 - wait around 10 min and connect to the master node using the adresse IP giving by Terraform
```bash
    ssh -i ./k8s_configuration/ssh-keys/id_rsa_sdtd ubuntu@<IP_Adress>
```
 - In the master node run : 
```bash
   sudo -i
```
 - The link to our application is in "ensimag-sdtd/adress_ip.txt", copy and paste the link in the browser to test the application
```bash
   cat ensimag-sdtd/adress_ip.txt
```

 ### If you want to delete resources:
- In the master node in ensimag-sdtd run:
```bash
  ./destroy_app.sh
```
- Exit the master node and in local in  "./k8s_configuration/cluster_config" run : 
```bash
  terraform destroy
```

https://tropars.github.io/downloads/lectures/SDTD/sdtd_presentation_2020.pdf
