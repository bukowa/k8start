
resource "null_resource" "k3d_cluster" {
  provisioner "local-exec" {
    when = create
    interpreter = ["bash", "-c"]
    command = <<EOT
              k3d cluster create ${var.cluster_name} \
              --servers=3 --k3s-arg='--disable=traefik@server:*' \
              -p '80:80@loadbalancer' -p '443:443@loadbalancer' \
              --verbose
              EOT
  }
  provisioner "local-exec" {
    when = destroy
    interpreter = ["bash", "-c"]
    command = "k3d cluster delete k8start"
  }
}
