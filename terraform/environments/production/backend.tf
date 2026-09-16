terraform {
  backend "s3" {
    bucket       = "farmdirect-tfstate-875061094302-ap-south-1"
    key          = "farmdirect/production/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}