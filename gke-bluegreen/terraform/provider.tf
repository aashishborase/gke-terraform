provider "google" {
  project = var.project_id
  region  = var.region
}


terraform {
  backend "gcs" {
    bucket = "gke-state-store"
    prefix = "terraform/gke/state"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "<=4.72.0"
    }
  }
}