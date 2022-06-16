# Generates an archive of the source code compressed as a .zip file.
data "archive_file" "source" {
    type        = "zip"
    source_dir  = "../src"
    output_path = "/tmp/function.zip"
}



# make a random ID to call, so each time we provision a resource the name is different
resource "random_id" "id" {
      byte_length = 8
}
# ${random_id.id.hex}   # this would get you different numbers



# Add source code zip to the Cloud Function's bucket
resource "google_storage_bucket_object" "zip" {
    source       = data.archive_file.source.output_path
    content_type = "application/zip"

    # Append to the MD5 checksum of the files's content
    # to force the zip to be updated as soon as a change occurs
    name         = "src-${data.archive_file.source.output_md5}.zip"
    bucket       = google_storage_bucket.function_bucket.name

    # Dependencies are automatically inferred so these lines can be deleted
    depends_on   = [
        google_storage_bucket.function_bucket,  # declared in `storage.tf`
        data.archive_file.source
    ]
}




## Make service account and add IAM roles
resource "google_service_account" "sa-name" {
  account_id = "sa-name-cloud-function2"
  display_name = "SA"
}

resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.function.project
  region         = google_cloudfunctions_function.function.region
  cloud_function = google_cloudfunctions_function.function.name

  role   = "roles/cloudfunctions.invoker"
  member = "serviceAccount:${google_service_account.sa-name-cloud-function2.email}"
}

resource "google_secret_manager_secret_iam_member" "member" {
  project = google_secret_manager_secret.secret-basic.project
  secret_id = google_secret_manager_secret.secret-basic.secret_id

  role = "roles/secretmanager.secretAccessor"
  member = "serviceAccount:${google_service_account.sa-name-cloud-function2.email}"
}







# Create the Cloud function triggered by a `Finalize` event on the bucket
# For full syntax on provisioning a cloud function: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudfunctions_function
resource "google_cloudfunctions_function" "function" {              
    name                  = "function-backup-connectivity-git"      # function name
    runtime               = "python38"  # of course changeable

    available_memory_mb   = 512

    # Get the source code of the cloud function as a Zip compression
    source_archive_bucket = google_storage_bucket.function_bucket.name   # function_bucket set in storage.tf
    source_archive_object = google_storage_bucket_object.zip.name

    # Must match the function name in the cloud function `main.py` source code
    entry_point           = "backup_connectivity_git"

    trigger_http          = true


    # Setting my email as service account as it has the most permissions
    service_account_email = "${google_service_account.sa-name-cloud-function2.email}"


    # These are needed if your cloud function access a secret
    secret_volumes {         # Note lack of '=' for assignment
        mount_path        = "projects/286910582913/secrets/PAT_token/versions/1"   # directory to secret you chose
        secret            = "PAT_token"    # ID of the secret
        #versions          = 1  # including this gave an error. Uses 'latest' by default if you comment it out
    }


    # set max time to provision. Default is 5 mins for all of these
    timeouts {
        create = "6m"
        update = "6m"
        delete = "6m"
      }


    ## Might let you specify the trigger url
    #https_trigger_url    = "https://us-central1-dft-dst-prt-connectivitymetric.cloudfunctions.net/function-backup-connectivity-git"
    

}



# IAM entry for all users to invoke the function. Think this doesn't help as user needs Secrets Manager access too, as my 
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.function.project
  region         = google_cloudfunctions_function.function.region
  cloud_function = google_cloudfunctions_function.function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}






