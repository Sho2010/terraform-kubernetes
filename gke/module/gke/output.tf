# The following outputs allow authentication and connectivity to the GKE Cluster.
output "client_certificate" {
  value = "${google_container_cluster.gke.master_auth.0.client_certificate}"
}

output "client_key" {
  sensitive = true
  value = "${google_container_cluster.gke.master_auth.0.client_key}"
}

output "cluster_ca_certificate" {
  value = "${google_container_cluster.gke.master_auth.0.cluster_ca_certificate}"
}
output "gcloud_auth_command" {
 value = "gcloud container clusters get-credentials ${var.cluster_name} --zone ${var.zone} --project ${var.project}"
}
