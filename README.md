# backup_git

Provision cloud function to clone internal Git repository and store it in GCS.

Losely based on https://towardsdatascience.com/deploy-cloud-functions-on-gcp-with-terraform-111a1c4a9a88

This doesn't work due to an error in accessing secrets

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>


Delete a cloud function: needs to know the region

> gcloud functions delete function-backup-connectivity-git --region=europe-west2




Run this to create resources & run startup scripts; then destroy all resources

> terraform apply && terraform destroy



Terraform considers all .tf files in a directory at one time: they are treated as if all in one document



<br>
<br>
<br>


#### Looking to the future: things one might do to provision a compute engine

Use "terraform apply && terraform destroy" to run everything monthly

Below is an example of terraform code to provision a GCE instance

```

# Create service account
resource "google_service_account" "default" {
  account_id   = "service_account_id"
  display_name = "Service Account"
}



# Create VPC network
resource "google_compute_network" "vpc_network" {
  name                    = "vpc-network"
  auto_create_subnetworks = true
}



# Create compute engine
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


  #### TO ADD script to run on boot



  #### TO ADD set service account
  

}




```


<br>
<br>
<br>

##### Steps one could follow to set up automatic provisioning of GCE, script running and teardown

Based on https://www.willianantunes.com/blog/2021/05/the-easiest-way-to-run-a-container-on-gce-with-terraform/

Create docker image with tech stack needed: linux, python38, python modules

In terraform: provision gce-container module which calls the container, which the GCE instance can then use

Bash or python script to call all the relevant python scripts



<br>
<br>
<br>

##### More notes on Compute Engine

You can only deploy one container for each VM instance. Consider Google Kubernetes Engine if you need to deploy multiple containers per VM instance.









