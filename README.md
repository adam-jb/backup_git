# backup_git

Based on https://towardsdatascience.com/deploy-cloud-functions-on-gcp-with-terraform-111a1c4a9a88





Delete a cloud function: needs to know the region

> gcloud functions delete function-backup-connectivity-git --region=europe-west2




Run this to create resources & run startup scripts; then destroy all resources

> terraform apply && terraform destroy



Terraform considers all .tf files in a directory at one time: they are treated as if all in one document






"""""" Things one might do to provision a compute engine
/*
Use "terraform apply && terraform destroy" to run everything monthly
*/

##### seems we can provision resources both in main.tf and function.tf
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
