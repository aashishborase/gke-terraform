resource "google_project_iam_member" "bastion" {
  project = var.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.bastion.email}"
}

resource "google_project_iam_member" "gke-node" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.gke-node.email}"
}