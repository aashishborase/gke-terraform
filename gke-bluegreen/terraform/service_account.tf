resource "google_service_account" "gke-node" {
  account_id   = "gke-node"
  display_name = "gke-node"
}

resource "google_service_account" "bastion" {
  account_id   = "bastion"
  display_name = "bastion"
}