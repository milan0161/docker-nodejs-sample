module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name  = "milan-stanisavljevic.${var.lambda_domain_name}"
  zone_id      = data.aws_route53_zone.lambda_hosted_zone.zone_id

  validation_method = "DNS"

  tags = var.resource_tags
}


data "aws_route53_zone" "lambda_hosted_zone" {
  name         = var.lambda_domain_name
  private_zone = false
}
//it will be configured later when i expose alb
resource "aws_route53_record" "node-app" {
  zone_id = data.aws_route53_zone.lambda_hosted_zone.zone_id
  name    = "milan-stanisavljevic.${var.lambda_domain_name}"
  type    = "A"

  alias {
    name = data.aws_lb.alb.dns_name
    zone_id = data.aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}


data "aws_lb" "alb" {
  depends_on = [helm_release.node-app-helm]
  tags = {
    "albselector" = var.alb_tag_selector
  }
}
