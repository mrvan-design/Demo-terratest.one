# VPC
resource "aws_vpc" "demo_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "demo-vpc" }
}

# Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.demo_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = { Name = "demo-subnet" }
}

# Security Group
resource "aws_security_group" "demo_sg" {
  name        = "demo-sg"
  description = "Allow all inbound"
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

# EC2
resource "aws_instance" "demo_ec2" {
  ami                    = "ami-12345678"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.demo_sg.id]

  tags = { Name = "demo-ec2" }
}
