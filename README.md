# OpsSchool Final Project

## About The Project
A small production environment for a Kandula web application on AWS

### Terraform
In the terraform folder you can find 3 modules;

 1. VPC module 
      - A VPC with 4 subnetes; 2 private and 2 public spreaded between 2 Avaliability zones.
      - Routing Tables
      - An internet gateway
      - 2 NAT gatways for the private subnets
 2. servers module 
      - ec2 instances with specific security groups and IAM roles(according to the applications needs)
      - ALB for the UI of the services
      - A private DNS hosted zone to serve the instances 
 3. EKS module(v17.24 from terraform registry) which includes 4 nodes

### Ansible
Except for the Ansible server itself all other installation and configurations are made by Ansible Roles:
 - Consul Server and Agents
 - Postgresql Server with Tables for kandula
 - Elastic and Kibana server
 - Grafana server
 - Prometheus Server
 - Filebeat agent
 - Jenkins agents (Java, AWS CLI, Kubectl, helm, Trivy, updating IP address on the Jenkins server)
 - Node Exporter

### KANCLI
A basic CLI script that allows managment of the EC2 instaces in this project 

      
## Prerequisites
* <a href="https://learn.hashicorp.com/tutorials/terraform/install-cli">Terraform cli</a>
* <a href="https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html">AWS cli</a>
* <a href="https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html">Configure AWS Profile</a>





