resource "google_container_node_pool" "primary" {
  name       = var.primary_node_pool_name
  location   = "${var.region}-a"
  cluster    = google_container_cluster.bluegreen_workloads.name
  node_count = var.primary_node_pool_count

  node_config {
    machine_type = var.primary_node_pool_machine_type
    disk_size_gb = var.disk_size_gb

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.gke-node.email
    oauth_scopes    = var.oauth_scopes
  }
}