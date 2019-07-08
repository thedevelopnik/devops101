provider "minikube" {}

resource "minikube" "cluster" {
  cpus = 2
  disk_size = "10g"
  memory = 2048
  kubernetes_version = "v1.15.0"
  iso_url = "https://storage.googleapis.com/minikube/iso/minikube-v1.2.0.iso"
}
