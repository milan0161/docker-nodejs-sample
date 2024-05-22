variable "resource_tags" {
  description = "This tag will represent owner of the resources"
  type        = map(string)
  default = {
    "Owner" = "Milan Stanisavljevic"
    "Terraform" = "true"
  }
}

variable "profile" {
  description = "AWS profile name"
  type        = string
  default     = "Vega-Milan-s"
}

variable "region" {
  description = "AWS default region"
  type        = string
  default     = "eu-central-1"
}

variable "vpc-cidr-block" {
  description = "VPC CIDR Block"
  type = string
  default = "172.16.0.0/16"
}

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

variable "lambda_domain_name" {
  type = string
  description = "The domain name"
  default = "lambda.devops.sitesstage.com"
}
