module "secrets_manager" {
  source = "terraform-aws-modules/secrets-manager/aws"

  description = "Create secret manager service"
  name = "milan-secrets"
  ignore_secret_changes = true

  secret_string = jsonencode({
    POSTGRES_USER=""
    POSTGRES_PASSWORD=""
    POSTGRES_DB=""
  })
 tags = var.resource_tags
}

data "aws_secretsmanager_secret_version" "secret-version" {
  secret_id = module.secrets_manager.secret_id
}