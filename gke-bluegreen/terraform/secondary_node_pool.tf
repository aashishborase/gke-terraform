resource "google_container_node_pool" "secondary" {
  name       = var.secondary_node_pool_name
  location   = "${var.region}-a"
  cluster    = google_container_cluster.detection_workloads.name
  node_count = var.secondary_node_pool_count

   autoscaling {
    min_node_count = 1
    max_node_count = 2
  }

  node_config {
    machine_type = var.secondary_node_pool_machine_type
    disk_size_gb = var.disk_size_gb

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.gke-node.email
    oauth_scopes    = var.oauth_scopes
  }
  
}