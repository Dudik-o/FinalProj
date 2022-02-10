
variable "region" {
  default     = "us-east-1"
  type        = string
  description = "Region where to create the instances"
}

variable "owner_tag" {
  default = "Adi Ophir"
  type    = string
}

variable "project_tag" {
  default = "final-project"
  type    = string
}


variable "instance_type" {
  default     = "t2.micro"
  description = "type of the server instance"
}


variable "key_name" {
  default = "project_key"
}

variable "key_file" {
  default = "id_rsa"
}


variable "number_of_consul_servers" {
  default = "3"
}

variable "number_of_jenkins_nodes" {
  default = "2"
}

variable "ami" {
  description = "ami (linux) to use"
  default     = "ami-00ddb0e5626798373"
}

variable "kubernetes_version" {
  default     = 1.21
  description = "kubernetes version"
}

variable "cluster_name" {
  default = "OpsSchool-Project"
}
