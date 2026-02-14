provider "aws" {
  region = "us-east-1"
}

# --- NEW: Automatically find the latest Ubuntu 24.04 AMI ---
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu Creator)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# --- RESOURCES ---

resource "tls_private_key" "my_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "rynza-key"
  public_key = tls_private_key.my_key.public_key_openssh
}

resource "local_file" "ssh_key" {
  content         = tls_private_key.my_key.private_key_pem
  filename        = "rynza-key.pem"
  file_permission = "0400"
}

resource "aws_security_group" "web_sg" {
  name        = "rynza-security-group"
  description = "Allow Web Traffic"

  # Allow SSH (Port 22) - Vital for Ansible!
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow App Ports (3000-5000)
  # This covers:
  # - 3000 (Frontend)
  # - 3001 (Admin)
  # - 4000 (Backend - Current)
  # - 5000 (Backend - Alternative)
  ingress {
    from_port   = 3000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic (So server can download Docker images)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web_server" {
  ami           = data.aws_ami.ubuntu.id  # Use the auto-found AMI
  instance_type = "t3.micro"              # CHANGED to t3.micro for new account compatibility
  key_name      = aws_key_pair.generated_key.key_name
  security_groups = [aws_security_group.web_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y docker.io
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -aG docker ubuntu
              sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              sudo chmod +x /usr/local/bin/docker-compose
              EOF

  tags = {
    Name = "Rynza-MERN-Server"
  }
}

output "server_ip" {
  value = aws_instance.web_server.public_ip
}
