provider "helm" {
  kubernetes {
    host = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
      command     = "aws"
    }
    
  }
    registry {
    url      = join("", ["oci://", module.ecr.repository_url])
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
   
}

resource "helm_release" "alb_controler" {
  name = "load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  version = "1.7.2"
  namespace = "alb"
  create_namespace = true
  chart = "aws-load-balancer-controller"

  set {
    name = "clusterName"
    value = module.eks.cluster_name
  }
  set {
    name = "awsRegion"
    value = var.region
  }
  set {
    name = "defaultTargetType"
    value = "ip"
  }
  set {
    name = "serviceAccount.create"
    value = true
  }
  set {
    name = "serviceAccount.name"
    value = "alb-controller"
  }
  set {
    name = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.iam_eks_role.iam_role_arn
  }
  set {
    name = "vpcId"
    value = module.vpc.vpc_id
  }
 set {
   name = "loadBalancerClass"
   value = "service.k8s.aws/alb"
 }
 set {
    name = "replicaCount"
    value = 1
 }
}

resource "helm_release" "pgsql" {
  name = "postgresql"
  create_namespace = true
  namespace = "vegait-training"
  repository = "https://charts.bitnami.com/bitnami"
  chart = "postgresql"
  version = 15.4

  set {
    name = "auth.database"
    value = lookup(jsondecode(sensitive(data.aws_secretsmanager_secret_version.secret-version.secret_string)), "POSTGRES_DB", "default")
  }
  set {
    name = "auth.username"
    value = lookup(jsondecode(sensitive(data.aws_secretsmanager_secret_version.secret-version.secret_string)), "POSTGRES_USER", "default")
  }
  set {
    name = "auth.password"
    value = lookup(jsondecode(sensitive(data.aws_secretsmanager_secret_version.secret-version.secret_string)), "POSTGRES_PASSWORD", "default")

  }
  set {
    name = "primary.persistence.size"
    value = "8Gi"
   }
   set {
     name = "primary.persistence.storageClass"
     value = kubernetes_storage_class.storage_class.metadata[0].name
   }
  set {
    name = "primary.persistence.volumeName"
    value = "psql-persistence-volume"
  }
  set {
    name = "serviceAccount.create"
    value = false
  }
}

//This is commented because it should be configure in next step.
resource "helm_release" "node-app-helm" {
  name = "node-app-repo"
  repository = join("", ["oci://", module.ecr.repository_registry_id, ".dkr.ecr.", var.region, ".amazonaws.com"])
  namespace = "vegait-training"
  chart = "node-app-repo"
  create_namespace = false
  version = "0.1.7"

  set {
    name = "app.port"
    value = 3000
  }

  set {
    name = "app.label"
    value = "node-app"
  }
  set {
    name = "app.replicas"
    value = 1
  }
  set {
    name = "secret.postgres_user"
    value = lookup(jsondecode(sensitive(data.aws_secretsmanager_secret_version.secret-version.secret_string)), "POSTGRES_USER", "default")
  }

  set {
    name = "secret.postgres_password"
    value = lookup(jsondecode(sensitive(data.aws_secretsmanager_secret_version.secret-version.secret_string)), "POSTGRES_PASSWORD", "default")
  }
   set {
    name = "secret.postgres_db_name"
    value =lookup(jsondecode(sensitive(data.aws_secretsmanager_secret_version.secret-version.secret_string)), "POSTGRES_DB", "default")
    }
  set {
    name = "config.hostname"
    value = "postgresql-hl"
  }

  set {
    name = "container.containerName"
    value = "node-app"
  }

  set {
    name = "container.image"
    value = module.ecr.repository_url
  }
  set{
    name = "container.tag"
    value = "docker-1.1.8"
  }
   set {
    name = "ingress.host"
    value = "milan-stanisavljevic.${var.lambda_domain_name}"
  }
  set {
    name =  "ingress.class"
    value = "alb"
  }
  # set {
  #   name = "config.secret"
  #   value = "regcred"
  # }

  set {
    name = "defaultTag.albselector"
    value = var.alb_tag_selector
  }
}