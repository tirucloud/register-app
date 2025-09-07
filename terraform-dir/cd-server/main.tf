# CD Server (Helm + ArgoCD) EC2 Instance
provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "cd_server" {
  ami           = var.ami_id
  instance_type = "t3.medium"
  key_name      = var.key_name
  subnet_id     = var.subnet_id
  vpc_security_group_ids = [aws_security_group.cd_server_sg.id]
  tags = {
    Name = "cd-server"
  }
}

resource "aws_security_group" "cd_server_sg" {
  name        = "cd-server-sg"
  description = "Allow Helm/ArgoCD access"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
