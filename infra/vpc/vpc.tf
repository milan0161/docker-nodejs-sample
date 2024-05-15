module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "node-app-vpc-ms"
  cidr = var.vpc-cidr-block

  azs             = var.vpc-azs
  private_subnets = [lookup(module.subnet_addrs.network_cidr_blocks, "sn-eu-private-A", "default"),lookup(module.subnet_addrs.network_cidr_blocks, "sn-eu-private-B", "default"), lookup(module.subnet_addrs.network_cidr_blocks, "sn-eu-private-C", "default")]
  public_subnets = [lookup(module.subnet_addrs.network_cidr_blocks, "sn-eu-public-A", "default"),lookup(module.subnet_addrs.network_cidr_blocks, "sn-eu-public-B", "default"), lookup(module.subnet_addrs.network_cidr_blocks, "sn-eu-public-C", "default")]
  database_subnets = [ lookup(module.subnet_addrs.network_cidr_blocks, "sn-eu-db-A", "default"),lookup(module.subnet_addrs.network_cidr_blocks, "sn-eu-db-B", "default"), lookup(module.subnet_addrs.network_cidr_blocks, "sn-eu-db-C", "default") ]


  enable_nat_gateway = true
    single_nat_gateway = true
    one_nat_gateway_per_az = false
    create_igw = true
  

  tags = var.resource_tags
}

module "subnet_addrs" {
  source = "hashicorp/subnets/cidr"

  base_cidr_block = module.vpc.vpc_cidr_block
  networks = [
    {
      name     = "sn-eu-private-A"
      new_bits = 2
    },
    {
      name     = "sn-eu-private-B"
      new_bits = 2
    },
     {
      name     = "sn-eu-private-C"
      new_bits = 2
    },
     {
      name     = "sn-eu-public-A"
      new_bits = 8
    },
    {
      name     = "sn-eu-public-B"
      new_bits = 8
    },
    {
      name     = "sn-eu-public-C"
      new_bits = 8
    },
    {
      name     = "sn-eu-db-A"
      new_bits = 8
    },
      {
      name     = "sn-eu-db-B"
      new_bits = 8
    },
      {
      name     = "sn-eu-db-C"
      new_bits = 8
    },
  ]
}
