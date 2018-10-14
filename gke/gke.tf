module "gke" {
  source = "./module/gke"
  project            = "${var.gcp_project}"
  cluster_name       = "${var.cluster_name}"
  password           = "${var.cluster_master_password}"
  initial_node_count = 2

  # kubectl ip rectriction
  master_authorized_networks_config = "${var.master_authorized_networks_config}"

  # prometheus settings
  allow_prometheus_nodeport  = "${var.allow_prometheus_nodeport}"
  prometheus_allow_networks  = "${var.prometheus_allow_networks}"

  # local exec
  auto_register_kubeconfig = "${var.auto_register_kubeconfig}"
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
