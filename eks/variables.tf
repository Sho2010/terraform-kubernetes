variable "cluster_names" {
  # 'shared' is constants
  description = "(Optional)Cluster names using this VPC e.g.  { kubernetes.io/cluster/${cluster_name} = shared } ref: https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html",

  type    = "map"
  default = {}
}

variable "vpc_name" {
  description = "(Required) Name of the VPC."
}

variable "cluster_name" {
  description = "(Required) Name of the cluster."
  default = "sample-cluster"
}
