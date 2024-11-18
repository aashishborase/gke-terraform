resource "google_container_cluster" "detection_workloads" {
  name     = var.cluster_name
  location = "${var.region}-a"

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.

  remove_default_node_pool = true
  initial_node_count       = 1

    node_config {
    machine_type = var.primary_node_pool_machine_type
    disk_size_gb = var.disk_size_gb
  }

  master_authorized_networks_config {
     cidr_blocks {
       cidr_block = "0.0.0.0/0"
       display_name = "public"
     }
   }

  private_cluster_config {
    enable_private_endpoint = false
    enable_private_nodes   = true 
    master_ipv4_cidr_block = "10.13.0.0/28"
  }

  # Define networking
  network    = google_compute_network.vpc_network.name
  subnetwork = google_compute_subnetwork.vpc_subnet.name
}