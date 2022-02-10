provider "aws" {
  profile = "Adi"
  region  = var.region
  default_tags {
    tags = {
      Project = var.project_tag
      Owner   = var.owner_tag
    }
  }
}

