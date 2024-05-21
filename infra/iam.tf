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
    aws_iam_policy.allow_deploy_eks_policy.arn
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
        }
  ]
}
EOF
}
resource "aws_iam_policy" "allow_deploy_eks_policy" {
  name        = "AllowDeployToEksPolicy"
  path        = "/"
  description = "This policy will allow GitHub actions to deploy to Eks"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
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
})
}



