terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.49.0"
    }
  }
}

provider "aws" {
  profile = var.profile
  region  = var.region

}

# module "aws_vpc" {
#   source = "./vpc"
# }

module "aws_assumable_github_role" {
  source = "./iam"
  aws_policy_region = var.region
  aws_resource_owner = var.resource_tags
}