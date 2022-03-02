resource "kubernetes_service" "backend" {
  metadata {
    name = "wordpress-mysql"
    labels = {
      app = "wordpress"
    }
    namespace = local.ns
  }
  spec {
    selector = {
      app = "wordpress"
      tier = "mysql"
    }
    port {
        port        = 3306
    }

    cluster_ip = "None"
  }
}

resource "kubernetes_persistent_volume_claim" "backend" {
  metadata {
    name = "mysql-pvc"
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

resource "kubernetes_deployment" "backend" {
  metadata {
    name = "wordpress-mysql"
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
        tier = "mysql"
      }
    }
    template {
      metadata {
        labels = {
          app = "wordpress"
          tier = "mysql"
        }
      }
      spec {
        container {
          image = "mysql:5.6"
          name  = "mysql"
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
            name = "MYSQL_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                name = "mysql-pass"
                key = "password"
              }
            }
          }
          port {
            container_port = "3306"
            name = "mysql"
          }
          volume_mount {
            name = "mysql-persistent-storage"
            mount_path = "/var/lib/mysql"
          }
        }
        volume {
          name = "mysql-persistent-storage"
          persistent_volume_claim {
            claim_name = "mysql-pvc"
          }
        }

          }
        }
      }
    }