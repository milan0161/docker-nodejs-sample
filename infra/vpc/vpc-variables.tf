variable "vpc-cidr-block" {
  description = "VPC CIDR Block"
  type = string
  default = "172.16.0.0/16"
}

variable "vpc-azs" {
  description = "List of azs"
  type = list(string)
  default = [ "eu-central-1a", "eu-central-1b", "eu-central-1c" ]
}

variable "resource_tags" {
  description = "This tag will represent owner of the resources"
  type = map(string)
  default = {
    "Owner" = "Milan Stanisavljevic",
    "Terraform" = "true"
  }
}