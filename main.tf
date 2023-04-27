terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {}

resource "aws_ecr_repository" "ecr-1" {
  name                 = "hello-ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecs_task_definition" "task-1" {
  family                   = "hello-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  container_definitions    = <<TASK_DEFINITION
[
  {
    "name": "iis",
    "image": "mcr.microsoft.com/windows/servercore/iis",
    "cpu": 1024,
    "memory": 2048,
    "essential": true
  }
]
TASK_DEFINITION

  runtime_platform {
    operating_system_family = "WINDOWS_SERVER_2019_CORE"
    cpu_architecture        = "X86_64"
  }
}

resource "aws_ecs_cluster" "cluster-1" {
  name = "hello-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_vpc" "vpc-1" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "hello-vpc"
  }
}

resource "aws_security_group" "sg-1" {
  name        = "hello-sg"
  vpc_id      = aws_vpc.vpc-1.id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.vpc-1.cidr_block]
    # ipv6_cidr_blocks = [aws_vpc.vpc-1.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "hello-sg"
  }
}

resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.vpc-1.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "subnet 1"
  }
}
resource "aws_subnet" "subnet-2" {
  vpc_id     = aws_vpc.vpc-1.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "subnet 2"
  }
}