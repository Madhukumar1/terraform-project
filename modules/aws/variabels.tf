variable "key_name" {
  description = "Name of the existing AWS Key Pair to use for EC2 instance"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}
