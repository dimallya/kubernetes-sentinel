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


resource "kubernetes_pod" "nginx" {
  metadata {
    name = "nginx-pod"
  }

  spec {
    container {

      # Missing or incorrect run_as_non_root setting
      security_context {
        run_as_user = 0
      }

      image = "nginx:1.7.8"
      name  = "nginx"

      port {
        container_port = 80
      }
    }
  }
}

resource "kubernetes_service" "nginx" {
  metadata {
    name = "nginx"
  }

  spec {
    selector {
      # NGINX pod labels are being referenced
      app = "${kubernetes_pod.nginx.metadata.0.labels.app}"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "${var.service_type}"
  }
}

variable "service_type" {
  default = "LoadBalancer"
}
