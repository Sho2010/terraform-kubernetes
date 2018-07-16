variable "gcp_project" {}
variable "gcp_region"  { default = "asia-northeast1" }

provider "google" {
  project     = "${var.gcp_project}"
  region      = "${var.gcp_region}"
}

