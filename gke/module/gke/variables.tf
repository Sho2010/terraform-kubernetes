variable "cluster_name"       {}
variable "project"            { default = "dev-playground-1019" }
variable "region"             { default = "asia-northeast1" }
variable "zone"               { default = "asia-northeast1-c" }
variable "machine_type"       { default = "n1-standard-1"}
variable "disk_size_gb"       { default = 100 }
variable "master_user"        { default = "admin" }
variable "password"           {}
variable "initial_node_count" { default = 3 }

variable "is_auth_kubectl" {
  description = "execute gcloud container clusters get-credentials command after cluster created."
  default     = "false"
}

variable "prometheus_port" {
  description = "(Optional)Firewall allow port for prometheus NodePort default:30080"
  default = 30080
}

variable "labels" {
  type = "list"
  default = [
    "terra", "true"
  ]
}

variable "tags" {
  type = "list"
  description = "tag for network firewall"
  # default = [ "${cluster_name}-prometheus-nodeport" ]
  default = [ "prometheus-nodeport" ]
}
