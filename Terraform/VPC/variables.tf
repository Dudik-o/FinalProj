variable "region" {
  default = "us-east-1"
  description = "Region where to create the instances"
}
variable "number_of_privsubnets" {
  description = "The number of private subnet to create"
}

variable "number_of_pubsubnets" {
  description = "The number of public subnet to create"
}

variable "owner_tag" {
  default = "Adi Ophir"
  type    = string
}

variable "project_tag" {
  default = "mid-project"
  type    = string
}

