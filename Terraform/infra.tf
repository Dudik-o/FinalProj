terraform {
  backend "s3" {
    bucket  = "mid-project"
    region  = "us-east-1"
    key     = "status"
    profile = "Adi"
  }
}

module "infra" {
  source                = "./VPC"
  number_of_pubsubnets  = 2
  number_of_privsubnets = 2
}
