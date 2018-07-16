variable "cluster_name" {
  default = "terraform-cluster"
}

variable "cluster_master_password" {}

module "gke" {
  source = "./module/gke"
  project            = "${var.gcp_project}"
  cluster_name       = "${var.cluster_name}"
  password           = "${var.cluster_master_password}"
  initial_node_count = 2

  is_auth_kubectl = "false"
}

# module outputは `$ terraform output` で直接見れない　めんどい
output "client_certificate" {
  value = "${module.gke.client_certificate}"
}

output "client_key" {
  sensitive = true
  value = "${module.gke.client_key}"
}

output "cluster_ca_certificate" {
  value = "${module.gke.cluster_ca_certificate}"
}

output "gcloud_auth_command" {
  description = "kubectl用 実行するとgcloud commandを使って接続情報を追加します"
  value = "${module.gke.gcloud_auth_command}"
}
