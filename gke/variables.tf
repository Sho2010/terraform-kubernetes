variable "cluster_name" {
  default = "terraform"
}

variable "cluster_master_password" {}

variable "auto_register_kubeconfig" {
  description = "(Optional) true: register created cluster authentication infomation to kubeconfig"
  default = false
}

variable "allow_prometheus_nodeport" {
  description = "(Optional)Create allow firewall for prometheus port if true"
  default     = "true"
}

variable "master_authorized_networks_config" {
  description = "prometheusとGKE clusterに接続可能なIP郡(CIDR block array)"

  default  = []
}

variable "prometheus_allow_networks" {
  description = ""
  default = []
}


