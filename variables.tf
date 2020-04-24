variable "client_id" {
  default = "client_id"
}
variable "client_secret" {
  default = "client_secret"
}

variable "cluster_name" {
  default = "w3f"
}

variable "location" {
  default = "switzerlandnorth"
}

variable "node_count" {
  default = 2
}

variable "machine_type" {
  default = "Standard_D2s_v3"
}

variable "k8s_version" {
  default = "1.16.7"
}
