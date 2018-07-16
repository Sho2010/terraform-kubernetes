resource "google_container_cluster" "gke" {
  name               = "${var.cluster_name}"
  zone               = "${var.zone}"
  initial_node_count = "${var.initial_node_count}"

  master_auth {
    username = "admin"
    password = "${var.password}"
  }

  node_config {
    machine_type = "${var.machine_type}"
    disk_size_gb = "${var.disk_size_gb}"

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
    command = "${var.is_auth_kubectl == "true" ? "gcloud container clusters get-credentials ${var.cluster_name} --zone ${var.zone} --project ${var.project}": "" }"
  }
}

# (Optional) Use for prometheus NodePort
resource "google_compute_firewall" "prometheus" {
  name    = "${var.cluster_name}-prometheus-firewall"
  network = "default" # TODO: other network support

  # ip restriction if require
  source_ranges = [ "0.0.0.0/0" ]

  allow {
    protocol = "tcp"
    ports    = ["30080"]
  }

  source_tags = "${var.tags}"
}
