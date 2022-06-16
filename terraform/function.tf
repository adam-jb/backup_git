# Generates an archive of the source code compressed as a .zip file.
data "archive_file" "source" {
    type        = "zip"
    source_dir  = "../src"
    output_path = "/tmp/function.zip"
}



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


    # These are needed if your cloud function access a secret
    secret_environment_variables {         # Note lack of '=' for assignment
        key               = "PAT_token"    # Name of the environment it returns. Not sure we use this, but including it enables python secrets manager to access secrets
        secret            = "PAT_token"    # ID of the secret
        version           = 1
    }

    
    # set max time to provision
    timeouts {
        create: "1m",
        update: "1m",
        delete: "1m"
      }


    ## Might let you specify the trigger url
    #https_trigger_url    = "https://us-central1-dft-dst-prt-connectivitymetric.cloudfunctions.net/function-backup-connectivity-git"
    

}



# IAM entry for all users to invoke the function
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.function.project
  region         = google_cloudfunctions_function.function.region
  cloud_function = google_cloudfunctions_function.function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}






