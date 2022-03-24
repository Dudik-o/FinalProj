
This project implements automation cloud infrastructure in AWS which include:
- VPC with 2 public subnet and 2 private subnets divided between 2 availabillity zones. 
- Internet Gateway
- NAT gatways assigned to the private subnets
- A key-pair for the instances within this project
- Bastion Host (public subnet)
- *jenkins server and 2 agents and a loadbalncer to allow 8080 traffic 
- Ansible server (private subnet)
- 3 Consul server (divided between the private subnets)
- Application loadbalncer to allow 8500 traffic to access the consul UI
- Prometheus server(private subnet) and a loadbalncer to allow 9090 traffic
- Grafna server(private subnet) and a loadbalncer to allow 3000 traffic
- Elastic server with kibana(private subnet)  and a loadbalncer to allow 5601 traffic
- EKS cluster with 4 nodes + YAML files to create secret, Deployment of 3 pods and a service


**jenkins server:
    - Created from a Private AMI
	- integrated with Git and Docker hub 
	- with a pipeline that can read the jenkinsfile in https://github.com/Dudik-o/kandula-project-app, create an image and push it to Dockerhub

**Ansible server with the follwing roles
	- Role for the jenkins agent (java, docker, helm, kubectl, aws cli)
	- playbook to update the jenkins agent IPs
	- consul servers
	- consul agents
	- Grafana server
	- Prometheus server
	- node_exporter
	- elastic and Kibana
	- Filebeat


Prerequisites:
Terraform is installed on your computer (version v1.1.2)
AWS porifle set on your computer (needs to be update on the profile_name varaible)
A S3 Bucket ( needs to be update on the bucket_name varaible) - for the terraform state




 
