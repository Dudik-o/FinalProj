# OpsSchool Final Project

## About The Project
A small production environment for a Kandula web application on AWS

### Terraform
3 modules are inclueded;
 1. VPC module 
      - A VPC with 4 subnetes; 2 private and 2 public spreaded between 2 Avaliability zones.
      - Routing Tables
      - An internet gateway
      - 2 NAT gatways for the private subnets
      -
      
## Prerequisites
* <a href="https://learn.hashicorp.com/tutorials/terraform/install-cli">Teraform cli</a>
* <a href="https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html">AWS cli</a>
* <a href="https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html">Configure AWS Profile</a>

## Usage
1. Clone the repository to your mechine

   
2. Set your AWS credentials as environment vars:
   <br />
   ```
   export AWS_ACCESS_KEY_ID=EXAMPLEACCESSKEY
   export AWS_SECRET_ACCESS_KEY=EXAMPLESECRETKEY
   export AWS_DEFAULT_REGION=us-east-1
 
 

