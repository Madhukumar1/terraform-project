
# vpc.tf or modules/vpc/main.tf
resource "aws_vpc" "vpc" {
  cidr_block = "172.27.0.0/16"
}
