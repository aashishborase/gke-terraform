resource "google_compute_firewall" "bastion-allow-ssh-http" {
  name    = "bastion-allow-ssh-http"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["8080","22"]
  }

  source_ranges = ["0.0.0.0/0"] # Allow SSH and HTTP from any IP address (adjust for security)
}

resource "google_compute_instance" "bastion_host" {
  name         = "bastion-host"
  machine_type = var.bastion_host_machine_type
  zone         = "${var.region}-a"

  boot_disk {
    initialize_params {
      image = "projects/debian-cloud/global/images/debian-11-bullseye-v20241009" # Ubuntu 20.04 LTS
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.vpc_subnet.name

    access_config {
      # Ephemeral public IP
    }
  }

  metadata_startup_script = <<-EOT
#!/bin/bash

# This is the Debian package repository of Jenkins to automate installation and upgrade. To use this repository, first add the key to your system (for the Weekly Release Line):

sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

# Then add a Jenkins apt repository entry:

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
/etc/apt/sources.list.d/jenkins.list > /dev/null

#Update your local package index, then finally install Jenkins:

sudo apt-get update -y
sudo apt-get install fontconfig openjdk-17-jre -y
sudo apt-get install jenkins -y

 
#password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword


# Add HashiCorp repository for Terraform

sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update  -y
sudo apt-get install terraform  -y


# Verify Terraform installation
terraform_version=$(terraform --version)
if [[ $? -eq 0 ]]; then
echo "Terraform installed successfully: $terraform_version"
else
echo "Terraform installation failed"
exit 1
fi


sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin -y
sudo apt-get install kubectl -y
  EOT

  tags = ["bastion"]

  service_account {
    email  = google_service_account.bastion.email
    scopes = var.oauth_scopes
  }
}

output "bastion_private_ip" {
  description = "The public IP address of the bastion host"
  value       = google_compute_instance.bastion_host.network_interface[0].access_config[0].nat_ip
}
