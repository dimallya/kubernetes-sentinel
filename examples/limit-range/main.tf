provider "kubernetes" {}

resource "kubernetes_limit_range" "example" {
    metadata {
        name = "sentinel-example"
    }
    spec {
        limit {
            type = "Pod"
            max = {
                cpu = "2500m"
                memory = "1024M"
            }
        }
        limit {
            type = "PersistentVolumeClaim"
            min = {
                storage = "24M"
            }
        }
        limit {
            type = "Container"
            default = {
                cpu = "50m"
                memory = "24M"
            }
       }
   }
 }

resource "kubernetes_deployment" "insecure_app" {
  metadata {
    name = "insecure-app"
    labels = {
      app = "insecure"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "insecure"
      }
    }

    template {
      metadata {
        labels = {
          app = "insecure"
        }
      }

      spec {
        container {
          name  = "insecure-container"
          image = "nginx:latest"

          # Missing or incorrect run_as_non_root setting
          security_context {
            run_as_user = 0
          }

          port {
            container_port = 80
          }
        }
      }
    }
  }
}
