terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"

    }
  }
}
provider "aws" {
  region = "us-east-1"

}

resource "aws_instance" "docker" {
  ami                    = local.ami
  instance_type          = "t3.medium"
  vpc_security_group_ids = [aws_security_group.ruler.id]
  user_data = templatefile("space.sh", {
    aws_access_key = var.aws_access_key
    aws_secret_key = var.aws_secret_key
  })


  tags = {
    Name        = "docker-instance"
    Environment = "dev"
    Project     = "docker-practice"
  }
  root_block_device {
    volume_size           = 50
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
    tags = {
      Name = "Docker-Disk-Size"

    }
  }

}

resource "terraform_data" "cluster_destroy" {
  input = {
    host     = aws_instance.docker.public_ip
    password = var.ssh_password
  }

  provisioner "remote-exec" {
    when = destroy
    inline = [
      "eksctl delete cluster -f /home/ec2-user/eksctl/eks.yaml --wait"
    ]
    connection {
      type     = "ssh"
      host     = self.input.host
      user     = "ec2-user"
      password = self.input.password
    }
  }
}

resource "aws_security_group" "ruler" {

  name        = "Docker-SG"
  vpc_id      = local.aws_vpc
  description = "Allow ssh and HTTPS inbound traffic"
  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }

  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  tags = {
    Name = "docker-sg"
  }

}

resource "aws_eip" "docker_ip" {
  instance = aws_instance.docker.id
  domain   = "vpc"
}
