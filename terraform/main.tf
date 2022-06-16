# Declare connection to google provider
provider "google" {
  project = var.project_id
  region  = var.region
}



# seems we can provision resources both in main.tf and function.tf
resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      image = "ubuntu-cloud/ubuntu-1804-lts"
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network       = google_compute_network.vpc_network.self_link
    access_config {
    }
  }


  # script to run on boot



  # service account
  



}



# VPC for compute engine instance
resource "google_compute_network" "vpc_network" {
  name                    = "terraform-network"
  auto_create_subnetworks = "true"
}
