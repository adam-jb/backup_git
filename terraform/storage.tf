# specify (presumbly new) storage bucket for storing the function (function bucket)
resource "google_storage_bucket" "function_bucket" {
    name     = "${var.project_id}-function"
    location = var.region
}
