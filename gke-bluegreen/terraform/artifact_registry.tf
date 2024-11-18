resource "google_artifact_registry_repository" "gke_bluegreen" {
  location      = var.region
  repository_id = "gke-bluegreen"
  description   = "gke bluegreen"
  format        = "DOCKER"

  docker_config {
    immutable_tags = true
  }
}