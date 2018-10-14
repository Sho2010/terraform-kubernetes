variable "cluster_name"       {}
variable "project"            {}
variable "region"             { default = "asia-northeast1" }
variable "zone"               { default = "asia-northeast1-c" }
variable "machine_type"       { default = "n1-standard-1"}
variable "disk_size_gb"       { default = 100 }
variable "master_user"        { default = "admin" }
variable "password"           {}
variable "initial_node_count" { default = 3 }

variable "allow_prometheus_nodeport" {
  description = "(Optional)Create allow firewall for prometheus port if true"
  default     = "true"
}

variable "master_authorized_networks_config" {
  # ref https://cloud.google.com/kubernetes-engine/docs/how-to/authorized-networks?hl=en
  type        = "list"
  description = "Authorized Networks for Master Access(kubectl access). Notice describing cidr block format"
  default     = []

  # e.g.
  /*
  master_authorized_networks_config  = [
    { cidr_block = "0.0.0.0/32", display_name = "allow all" },
  ]
  */

}

variable "auto_register_kubeconfig" {
  description = "execute gcloud container clusters get-credentials command after cluster created."
  default     = "false"
}

variable "prometheus_port" {
  description = "(Optional)Firewall allow port for prometheus NodePort default:30080"
  default = 30080
}

variable "prometheus_allow_networks" {
  description = "(Optional)Firewall allow networks"
  type = "list"
  default = [ "0.0.0.0/0" ]
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
  default = [ "prometheus-nodeport" ]
}
