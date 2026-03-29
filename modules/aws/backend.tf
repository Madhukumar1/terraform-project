terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-123"
    key            = "terraform-project/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
