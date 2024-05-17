module "iam_github_oidc_provider" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-github-oidc-provider"

  tags = {
    Owner = "Milan Stanisavljevic"
  }
}

module "iam_assumable_role_with_oidc" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"

  create_role = true

  role_name = "role-with-oidc"

  oidc_subjects_with_wildcards = [
    "repo:${var.github_profile}/${var.github_repo.node_app_repo}:ref:refs/heads/*",
    "repo:${var.github_profile}/${var.github_repo.node_app_repo}:ref:refs/tags/*"
  ]

  oidc_fully_qualified_audiences = ["sts.amazonaws.com"]

  provider_url = module.iam_github_oidc_provider.url

  role_policy_arns = [
    "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
  ]
  
  tags = {
    Role = "role-with-oidc"
    Owner = "Milan Stanisavljevic"
  }
}

