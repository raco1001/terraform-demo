terraform {
  cloud {
    organization = "PRG_CICD"
    workspaces {
      name = "nginx-example"
    }
  }
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

variable "kubernetes_config_path" {
  default = "~/.kube/config"
}

variable "kubernetes_namespace" {
  default = "default"
}

provider "kubernetes" {
  config_path = var.kubernetes_config_path
}

resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "nginx-example"
    labels = {
      App = "NginxExample"
    }
    namespace = var.kubernetes_namespace
  }

  spec {
    replicas = 4
    selector {
      match_labels = {
        App = "NginxExample"
      }
    }
    template {
      metadata {
        labels = {
          App = "NginxExample"
        }
      }
      spec {
        container {
          image = "nginx:1.27"
          name = "example"

          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nginx" {
  metadata {
    name = "nginx-example"
    namespace = var.kubernetes_namespace
  }
  spec {
    selector = {
      App = kubernetes_deployment.nginx.spec.0.template.0.metadata[0].labels.App
    }
    port {
      node_port   = 30201
      port        = 80
      target_port = 80
    }
    type = "NodePort"
  }
}

