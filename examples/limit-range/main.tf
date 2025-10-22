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

resource "kubernetes_deployment" "example" {
  metadata {
    name = "my-app-deployment"
    labels = {
      app = "my-app"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "my-app"
      }
    }
    template {
      metadata {
        labels = {
          app = "my-app"
        }
      }
      spec {
        container {
          name  = "my-app-container"
          image = "nginx:latest" # Replace with your desired image
          security_context {
            run_as_user              = 0 # Specify a non-root user ID
            allow_privilege_escalation = true
          }
        }
      }
    }
  }
}
