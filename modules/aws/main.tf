# Terraform AWS Module

# Best practices implementation

variable "vpc_cidr" {  
type        = string  
description = "The CIDR block for the VPC"
}

resource "aws_vpc" "main" {  
  cidr_block = var.vpc_cidr  
  tags = {    
    Name = "Main VPC"  
    Environment = var.environment  
  }
}

variable "ami_id" {
type        = string
description = "The AMI ID to use for the instance"
}

variable "instance_type" {  
type    = string  
default = "t2.micro"  
  validation {    
    condition = contains(["t2.micro", "t2.small", "t2.medium", "t3.micro", "t3.small", "t3.medium"], var.instance_type)    
    error_message = "Invalid instance type. Must be one of: t2.micro, t2.small, t2.medium, t3.micro, t3.small, t3.medium."  
  }
}

resource "aws_instance" "example" {  
  ami           = var.ami_id  
  instance_type = var.instance_type  
  tags = {    
    Name = "Example Instance"  
    Environment = var.environment  
  }
  root_block_device {    
    volume_type = "gp3"    
    volume_size = 20    
  }
  timeouts {  
    create = "1h"  
    update = "1h"  
    delete = "1h"  
  }
}

output "instance_id" {  
  value = aws_instance.example.id  
}

output "vpc_id" {  
  value = aws_vpc.main.id  
}

variable "enable_logging" {  
type    = bool  
default = true  
}

variable "environment" {  
type        = string  
description = "Deployment environment (e.g. dev, staging, prod)"
}
