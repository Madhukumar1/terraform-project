variable "allowed_ssh_cidr" {
  description = "CIDR block for SSH access"
  type        = string
  validation {
    condition     = can(cidrhost(var.allowed_ssh_cidr, 0))
    error_message = "Must be a valid CIDR block (e.g., '203.0.113.42/32')."
  }
}

variable "key_name" {
  description = "EC2 Key Pair name"
  type        = string
}

variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t2.micro"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

# Data source for latest Ubuntu AMI (region-agnostic)
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_security_group" "ec2_ssh" {
  name_prefix = "ec2-ssh-"
  description = "Allow SSH inbound traffic"
  
  tags = {
    Name        = "${var.environment}-ec2-ssh"
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.ec2_ssh.id

  description = "SSH access from authorized IPs only"
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
  cidr_ipv4   = var.allowed_ssh_cidr

  tags = {
    Name = "${var.environment}-ssh-ingress"
  }
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.ec2_ssh.id

  description = "Allow all outbound traffic"
  from_port   = -1
  to_port     = -1
  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"

  tags = {
    Name = "${var.environment}-egress-all"
  }
}

resource "aws_instance" "myec2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.ec2_ssh.id]

  monitoring              = true
  associate_public_ip_address = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"  # Prevent SSRF attacks
    http_put_response_hop_limit = 1
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true
    encrypted             = true  # Enable EBS encryption

    tags = {
      Name = "${var.environment}-root-volume"
    }
  }

  tags = {
    Name        = "${var.environment}-ec2-instance"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  depends_on = [aws_vpc_security_group_ingress_rule.ssh]
}

output "instance_id" {
  value       = aws_instance.myec2.id
  description = "EC2 Instance ID"
}

output "instance_public_ip" {
  value       = aws_instance.myec2.public_ip
  description = "Public IP of the EC2 instance"
}
