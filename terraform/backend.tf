# specify where backend is hosted
terraform {
  backend "gcs" {
    bucket  = "tf-state-prod-test901"
    prefix  = "terraform/state"
  }
}