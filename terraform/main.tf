
resource "null_resource" "wait_for_localstack" {
  provisioner "local-exec" {
    command = <<EOT
      echo "Waiting for LocalStack EC2 service..."
      until curl -s http://localhost:4566/_localstack/health | grep -q '"ec2":"running"'; do
        sleep 2
      done
      echo "LocalStack EC2 is ready!"
    EOT
  }
}

# =========================================
# Tạo VPC
# =========================================
resource "aws_vpc" "demo_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "demo-vpc"
  }

  depends_on = [null_resource.wait_for_localstack]
}

# =========================================
# Tạo Subnet
# =========================================
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.demo_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "demo-subnet"
  }
}

# =========================================
# Tạo Security Group
# =========================================
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

# =========================================
# Tạo EC2 instance (fake AMI của LocalStack)
# =========================================
resource "aws_instance" "demo_ec2" {
  ami                    = "ami-12345678"  # LocalStack fake AMI
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.demo_sg.id]
  tags = {
    Name = "demo-ec2"
  }
}
