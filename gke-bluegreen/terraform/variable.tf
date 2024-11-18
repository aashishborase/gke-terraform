variable "project_id" {
  description = "The ID of the GCP project"
  type        = string
}

variable "region" {
  description = "The region where resources will be created"
  type        = string
}

variable "backend_bucket" {
  description = "The backend bucket for GCP resources"
  type        = string
}

variable "cluster_name" {
  description = "name of the cluster"
  type        = string
}

variable "primary_node_pool_machine_type" {
  description = "The machine type for the primary node pool"
  type        = string
}

variable "secondary_node_pool_machine_type" {
  description = "The machine type for the secondary node pool"
  type        = string
}

variable "bastion_host_machine_type" {
  description = "The machine type for the bastion host"
  type        = string
}

variable "oauth_scopes" {
  description = "OAuth scopes required for accessing GCP services"
  type        = list(string)
}

variable "primary_node_pool_name" {
  description = "Name of the primary node pool"
  type        = string
}

variable "secondary_node_pool_name" {
  description = "Name of the secondary node pool"
  type        = string
}

variable "primary_node_pool_count" {
  description = "The number of nodes in the primary node pool"
  type        = number
}

variable "secondary_node_pool_count" {
  description = "The number of nodes in the secondary node pool"
  type        = number
}

variable "disk_size_gb" {
  description = "disk_size_gb"
  type        = number
  default = 10
}

