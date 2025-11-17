provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  s3_force_path_style         = true
  endpoints {
    ec2 = "http://host.docker.internal:4566"
  }
}

# =====================
# VPC
# =====================
resource "aws_vpc" "demo_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "demo-vpc"
  }
}

# =====================
# Public Subnet
# =====================
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.demo_vpc.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "demo-subnet"
  }
}

# =====================
# Security Group
# =====================
resource "aws_security_group" "demo_sg" {
  name        = "demo-sg"
  description = "Allow all inbound for LocalStack testing"
  vpc_id      = aws_vpc.demo_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# =====================
# EC2 Instance
# =====================
resource "aws_instance" "demo_ec2" {
  ami           = "ami-12345678"   # placeholder, LocalStack sẽ chấp nhận
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.demo_sg.id]

  tags = {
    Name = "demo-ec2"
  }

  # đảm bảo EC2 chạy sau SG & Subnet
  depends_on = [
    aws_security_group.demo_sg,
    aws_subnet.public
  ]
}

# =====================
# Outputs
# =====================
output "vpc_id" {
  value = aws_vpc.demo_vpc.id
}

output "subnet_id" {
  value = aws_subnet.public.id
}

output "sg_id" {
  value = aws_security_group.demo_sg.id
}

output "instance_id" {
  value = aws_instance.demo_ec2.id
}
