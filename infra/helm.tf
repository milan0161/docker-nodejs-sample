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
