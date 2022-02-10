
This project implements automation cloud infrastructure in AWS which include:
- VPC with 2 public subnet and 2 private subnets divided between 2 availabillity zones. 
- Internet Gatway
- NAT gatways assigned to the private subnets
- A key-pair for the instances within this project
- Bastion Host (public subnet)
- jenkins server and an agent*
- Ansible server (private subnet)*
- 3 Consul server (divided between the private subnets)
- Application loadbalncer to allow 8500 traffic to access the consul UI
- EKS cluster with 4 nodes + YAML files to create secret, Deployment of 3 pods and a service


**jenkins server:
	- integrated with Git and Docker hub 
	- with a pipeline that can read the jenkinsfile in https://github.com/Dudik-o/kandula-project-app, create an image and push it to Dockerhub

**Ansible server:
	- Role for configure the jenkins agent (java, docker)
	- Role for consul server configuration 


Prerequisites:
Terraform is installed on your computer (version v1.1.2)
AWS porifle set on your computer (needs to be update on the profile_name varaible)
A S3 Bucket ( needs to be update on the bucket_name varaible) - for the terraform state
install kubectl and aws cli


To Do:
 - Jenkins: - Add stages to the pipeline to run also the kubectl commands 
            - Find a solution for the node(s) ssh key to be updated automaticly
            - Find a way to run the build automaticly 

 - Ansible   - Ansible my scripts 

 