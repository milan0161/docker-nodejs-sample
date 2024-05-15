terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.49.0"
    }
  }
}

provider "aws" {
  profile = var.profile
  region = var.region

}

module "aws_vpc" {
  source = "./vpc"
}

