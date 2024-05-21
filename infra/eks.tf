module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "milan-s-cluster"
  cluster_version = "1.29"

  cluster_endpoint_public_access  = true
  #Ovo je public endpoint
  cluster_endpoint_public_access_cidrs = ["80.93.252.50/32"]
  #Cluster private endpoint access
  cluster_endpoint_private_access = true

  vpc_id  =  module.vpc.vpc_id
  subnet_ids  = module.vpc.private_subnets

  # EKS Managed Node Group(s)
  eks_managed_node_groups = {
    milan-s-node-group = {
     create_iam_role = true    
     iam_role_additional_policies = {
        AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
     }
      min_size     = 1
      max_size     = 10
      desired_size = 1
      ami_type = "BOTTLEROCKET_x86_64"
      instance_types = ["t3.small"]
      capacity_type  = "ON_DEMAND"
    }
  }

  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true
  tags = var.resource_tags
}



