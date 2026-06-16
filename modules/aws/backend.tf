terraform {
  backend "s3" {
    bucket         = "my-tf-test123-bucket12345"
    key            = "terraform-project/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
