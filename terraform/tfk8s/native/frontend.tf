resource "kubernetes_service" "frontend" {
  metadata {
    name = "wordpress"
    labels = {
      app = "wordpress"
    }
    namespace = local.ns
  }
  spec {
    selector = {
      app = "wordpress"
      tier = "frontend"
    }
    port {
        port        = 80
    }
    type = "LoadBalancer"
  }
}

resource "kubernetes_persistent_volume_claim" "frontend" {
  metadata {
    name = "wp-pvc"
    labels = {
      app = "wordpress"
    }
    namespace = local.ns
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}

resource "kubernetes_deployment" "frontend" {
  metadata {
    name = "wordpress"
    labels = {
      app = "wordpress"
    }
    namespace = local.ns
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "wordpress"
        tier = "frontend"
      }
    }
    template {
      metadata {
        labels = {
          app = "wordpress"
          tier = "frontend"
        }
      }
      spec {
        container {
          image = "wordpress:4.8-apache"
          name  = "wordpress"
          resources {
            limits = {
              cpu    = "0.5"
              memory = "256Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
          env {
            name = "WORDPRESS_DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = "mysql-pass"
                key = "password"
              }
            }
          }
          env {
            name = "WORDPRESS_DB_HOST"
            value = "wordpress-mysql" 
          }
          port {
            container_port = "80"
            name = "wordpress"
          }
          volume_mount {
            name = "wordpress-persistent-storage"
            mount_path = "/var/www/html"
          }
        }
        volume {
          name = "wordpress-persistent-storage"
          persistent_volume_claim {
            claim_name = "wp-pvc"
          }
        }

          }
        }
      }
    }