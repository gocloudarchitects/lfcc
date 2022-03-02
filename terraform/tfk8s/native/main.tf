terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "microk8s"
}

locals {
  ns = "wordpress"
}

resource "kubernetes_namespace" "wordpress-exercise" {
  metadata {
    name = local.ns
  }
}


resource "kubernetes_secret" "mysql-pass" {
  metadata {
    name = "mysql-pass"
    namespace = local.ns
  }
  data = {
    password = "secretpassword"
  }
}
