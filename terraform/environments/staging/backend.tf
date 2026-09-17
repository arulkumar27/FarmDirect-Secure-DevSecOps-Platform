# Local backend for a fresh clone. Replace with an S3 backend for shared CI state.
terraform {
  backend "local" {}
}