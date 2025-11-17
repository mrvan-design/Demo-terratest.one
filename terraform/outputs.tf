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
