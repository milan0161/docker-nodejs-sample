variable "resource_tags" {
  description = "This tag will represent owner of the resources"
  type = map(string)
  default = {
    "Owner" = "Milan Stanisavljevic"
  }
}

variable "profile" {
  description = "AWS profile name"
  type = string
  default = "Vega-Milan-s"
}

variable "region" {
  description = "AWS default region"
  type = string
  default = "eu-central-1"
}