terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

#Configuring the provider
provider "aws" {
  region = "us-east-1"
}

#Configuriung Jenkins instance
resource "aws_instance" "lup-jenkins" {
  ami                         = "ami-00ca32bbc84273381"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.lup-jenkins-sg.id]
  user_data                   = file("jenkins_installation.sh")

  #iam_instance_profile
  tags = {
    Name = "LUP-JENKINS"
  }
}

#Jenkins Security Groups
resource "aws_security_group" "lup-jenkins-sg" {
  name        = "lup-jenkins-sg"
  description = "Configured to Allow Traffic on Port 22,8080, 443 and 80"


  ingress {
    description = "Allow SSH Traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow Jenkins Traffic"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS Traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
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

resource "aws_s3_bucket" "project1-jenkins-bucket" {
  bucket = "jenkins-s3-bucket-eric-gold2025"

  tags = {
    Name = "LUP-JENKINS-BUCKET"
  }
}

resource "aws_s3_bucket_acl" "project1-jenkins-bucket-acl" {
  bucket     = aws_s3_bucket.project1-jenkins-bucket.id
  acl        = "private"
  depends_on = [aws_s3_bucket_ownership_controls.project1-jenkins-bucket-ownership]
}


resource "aws_s3_bucket_ownership_controls" "project1-jenkins-bucket-ownership" {
  bucket = aws_s3_bucket.project1-jenkins-bucket.id

  rule {
    object_ownership = "ObjectWriter"
  }
}

#backend for logs/terraform statefile

terraform {
  backend "s3" {
    bucket = "luit-terraform-project1-08242025"
    key    = "luit-terraform-project1-08242025/terraform/state.tf"
    region = "us-east-1"
  }
}

#outputs

output "bucket_name" {
  value = aws_s3_bucket.project1-jenkins-bucket.id
}

output "instance_id" {
  value = aws_instance.lup-jenkins.id
}

output "jenkins_url" {
  value = "http://${aws_instance.lup-jenkins.public_ip}:8080"
}

output "jenkins_ip" {
  value = aws_instance.lup-jenkins.public_ip
}

output "jenkins_security_group_id" {
  value = aws_security_group.lup-jenkins-sg.id
}