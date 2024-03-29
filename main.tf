# Define provider
provider "aws" {
  region = "us-east-1" # Change to your desired region
}

variable "hosted_zone_id" {
  default = "Z086548UEMAS55"
}

# Create security group
resource "aws_security_group" "instance_sg" {
  name        = "allow-all-my-ip"
  description = "allow all from my IP"

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Allow inbound traffic from Prometheus instance
  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    security_group_id = aws_security_group.prom_sg.id
  }
}

# Create security group for Prometheus instance
resource "aws_security_group" "prom_sg" {
  name        = "prometheus-sg"
  description = "security group for Prometheus instance"

  # Allow inbound traffic from node-exporter instance
  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    security_group_id = aws_security_group.instance_sg.id
  }
}

# Create EC2 instance for prom
resource "aws_instance" "prom" {
  ami           = "ami-0c88b8560fd9b0353" # Change to your desired AMI ID
  instance_type = "t2.large" # Change to your desired instance type
  vpc_security_group_ids = [aws_security_group.prom_sg.id] # Attach security group
  key_name = "sreuni"
  tags = {
    Name = "demo-prom-server"
  }
}

# Create EC2 instance for appserver-exporter
resource "aws_instance" "appserver-exporter" {
  ami           = "ami-05fba1dd756df8ac0" # custom AMI
  instance_type = "t2.large" # Change to your desired instance type
  vpc_security_group_ids = [aws_security_group.instance_sg.id] # Attach security group
  key_name = "sreuni"

  tags = {
    Name = "demo-exporter-appserver"
  }

  user_data = <<-EOF
    #!/bin/bash
    git clone https://github.com/si3mshady/demo-day-sreuni.git
    cd /demo-day-sreuni
    sudo docker build . -t taban-expense-app && sudo docker run -p 80:8501 taban-expense-app
  EOF
}

# Create Elastic IP for prom instance
resource "aws_eip" "eip" {
  instance = aws_instance.prom.id
}

# Create Elastic IP for appserver-exporter instance
resource "aws_eip" "eip2" {
  instance = aws_instance.appserver-exporter.id
}

# Create Route 53 record
resource "aws_route53_zone" "fqdn" {
  name = "sreuniversity.org"
}

resource "aws_route53_record" "fqdn_record" {
  zone_id = var.hosted_zone_id 
  name    = "demo.sreuniversity.org"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.eip2.public_ip]
}
