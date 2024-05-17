variable "vpc-cidr-block" {
  description = "VPC CIDR Block"
  type = string
  default = "172.16.0.0/16"
}

variable "resource_tags" {
  description = "This tag will represent owner of the resources"
  type = map(string)
  default = {
    "Owner" = "Milan Stanisavljevic",
    "Terraform" = "true"
  }
}