# Define provider
provider "aws" {
  region = "us-east-1" # Change to your desired region
}

# Create security group
resource "aws_security_group" "instance_sg" {
  name        = "allow-all-my-ip"
  description = "allow all from my ip"
}

# Add inbound rule to allow all ports from your IP address
resource "aws_security_group_rule" "allow_all_ports" {
  security_group_id = aws_security_group.instance_sg.id
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["70.224.95.9/32"] # Replace with your IP address
}

# Create EC2 instance
resource "aws_instance" "prom" {
  ami           = "prom-ami" # Change to your desired AMI ID
  instance_type = "t2.large" # Change to your desired instance type
  security_group_ids = [aws_security_group.instance_sg.id] # Attach security group

  tags = {
    Name = "demo-prom-server"
  }

  user_data = <<-EOF
              #!/bin/bash
             
             
              EOF
}

# Create EC2 instance
resource "aws_instance" "exporter" {
  ami           = "exporter-ami" # Change to your desired AMI ID
  instance_type = "t2.large" # Change to your desired instance type
  security_group_ids = [aws_security_group.instance_sg.id] # Attach security group

  tags = {
    Name = "demo-exporter-appserver"
  }

  user_data = <<-EOF
              #!/bin/bash
             
             
              EOF
}


# Create Elastic IP
resource "aws_eip" "eip" {
  instance = aws_instance.appserver.id
}

# Create Elastic IP
resource "aws_eip" "eip2" {
  instance = aws_instance.exporter.id
}


# Create Route 53 record
resource "aws_route53_zone" "fqdn" {
  name = "sreuniversity.org"
}

resource "aws_route53_record" "fqdn_record" {
  zone_id = aws_route53_zone.fqdn.zone_id
  name    = "sreuniversity.org"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.eip2.public_ip]
}
