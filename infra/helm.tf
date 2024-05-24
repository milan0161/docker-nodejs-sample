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
  namespace = var.k8s_namespace
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
    name = "serviceAccount.create"
    value = true
  }
  set {
    name = "serviceAccount.name"
    value = var.eks_service_account_name
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