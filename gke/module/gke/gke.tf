resource "google_container_cluster" "gke" {
  name               = "${var.cluster_name}"
  zone               = "${var.zone}"
  initial_node_count = "${var.initial_node_count}"
  min_master_version = "1.10.7-gke.6"

  # TODO: var設定時のみ設定する
  # master_authorized_networks_config = {
  #   cidr_blocks = "${var.master_authorized_networks_config}"
  # }

  master_auth {
    username = "admin"
    password = "${var.password}"
  }

  node_config {
    machine_type = "${var.machine_type}"
    disk_size_gb = "${var.disk_size_gb}"
    preemptible  = "true"

    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_write",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/bigquery",
      "https://www.googleapis.com/auth/pubsub",
    ]

    # labels {}

    tags = "${var.tags}"
  }

  provisioner "local-exec" {
    command = "${var.auto_register_kubeconfig == "true" ? "gcloud container clusters get-credentials ${var.cluster_name} --zone ${var.zone} --project ${var.project}": "" }"
  }
}

# (Optional) Use for prometheus NodePort
resource "google_compute_firewall" "prometheus" {
  count  = "${var.allow_prometheus_nodeport == "true" ? 1 : 0 }"

  name    = "${var.cluster_name}-prometheus-firewall"
  network = "default" # TODO: other network support

  # ip restriction if require
  source_ranges = "${var.prometheus_allow_networks}"

  allow {
    protocol = "tcp"
    ports    = ["${var.prometheus_port}"]
  }

  target_tags = "${var.tags}"
}
