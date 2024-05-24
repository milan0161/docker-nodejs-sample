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
    module.iam_policy.arn,
  ]
  
  tags = {
    Role = "role-with-oidc"
    Owner = "Milan Stanisavljevic"
  }
}


module "iam_policy"{
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"

  name        = "EcrAllowPushPolicy"
  create_policy = true
  description = "Policy which will allow our github workflow to push image to our ecr"
  tags = var.resource_tags
  policy = <<EOF
{
  "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchGetImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:PutImage"
            ],
            "Resource": "${module.ecr.repository_arn}"
        },
        {
            "Effect": "Allow",
            "Action": [
                "eks:DescribeCluster",
                "eks:DescribeNodegroup",
                "eks:ListClusters",
                "eks:ListNodegroups"
            ],
            "Resource": "${module.eks.cluster_arn}"
        }
  ]
}
EOF
}


module "iam_eks_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "eks-lb-irsa"
  
  attach_load_balancer_controller_policy = true
  ### Namespace and service account will be changed when lb is implemented.
  oidc_providers = {
    eks = {
      provider_arn               = "${module.eks.oidc_provider_arn}"
      namespace_service_accounts = ["${var.k8s_namespace}:${var.eks_service_account_name}"]
    }
  }
  tags = var.resource_tags
}