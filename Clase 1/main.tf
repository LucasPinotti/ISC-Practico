provider "aws" {
    region = "us-east-1"
    profile = "default"
}

resource "aws_vpc" "practico-terraform-vpc" {
  cidr_block           = var.vpc_cdir ##Bloque cidr pasado por variable.
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "test-terraform-vpc"
  }
}

resource "aws_subnet" "practico-terraform-subnet" {
  vpc_id                  = aws_vpc.practico-terraform-vpc.id #Asociamos un recurso creado con terraform
  cidr_block              = var.private_subnet ## Notar la variable para el cidr block de la subnet
  availability_zone       = var.vpc_aws_az ##Notar la variable para la AZ asignada a la subnet
  map_public_ip_on_launch = "true"
  tags = {
    Name = "test-terraform-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
      vpc_id = "${aws_vpc.practico-terraform-vpc.id}"
    }

resource "aws_security_group" "securitygorups" {
  name = "sec-grp"
  description = "Allow HTTP and SSH traffic via Terraform"

  ingress {
    from_port   = 80
    to_port     = 80
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

  vpc_id = aws_vpc.practico-terraform-vpc.id
}

resource "aws_instance" "aws_useast1_prod" {
    ami = "ami-051f7e7f6c2f40dc1"
    instance_type = "t2.medium"
    key_name = "vockey"
    subnet_id = aws_subnet.practico-terraform-subnet.id
    security_groups = [ "${aws_security_group.securitygorups.id}" ]
    tags = {
        Name = "ec2-prod"
        terraform = "True"
    }
}
