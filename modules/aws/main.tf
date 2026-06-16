# Terraform AWS Module
# Best practices implementation

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name        = "Main VPC"
    Environment = var.environment
  }
}

# Add a subnet resource
resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "172.31.0.0/16"      # Adjust based on your vpc_cidr
  availability_zone = "${var.aws_region}a" # You'll need to add this variable

  tags = {
    Name        = "Main Subnet"
    Environment = var.environment
  }
}

# Update the EC2 instance resource
resource "aws_instance" "myec2" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.main.id # Add this line

  tags = {
    Name        = "Example Instance"
    Environment = var.environment
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
  }
}

output "instance_id" {
  value = aws_instance.myec2.id
}

output "vpc_id" {
  value = aws_vpc.main.id
}
####
