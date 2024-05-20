variable "github_profile" {
  description = "Name of the github profile"
  type = string
  default = "milan0161"
}

variable "github_repo" {
  description = "Name of the github repositories"
  type = map(string)
  default = {
    node_app_repo = "docker-nodejs-sample"
  }
}

variable "aws_policy_region" {
  description = "AWS region name"
}

variable "aws_resource_owner" {
  description = "Owner of the created resource"
}
