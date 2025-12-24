terraform {
  backend "s3" {
    bucket = "my-tf-test123-bucket12345"
    key    = "terraform.tfstate"
    region = "ap-south-1"
  }
}