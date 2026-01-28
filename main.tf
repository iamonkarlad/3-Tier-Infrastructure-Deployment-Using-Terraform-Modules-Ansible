provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "./modules/vpc"
  vpc_cidr = "10.0.0.0/16"

  public_subnet = ["10.0.10.0/24", "10.0.20.0/24"]
  private_subnet = ["10.0.100.0/24", "10.0.200.0/24"]

  az = ["us-east-1a","us-east-1b"]
}                                                   

#------------------- security groups -------------------#

resource "aws_security_group" "web_sg" {
  name = "web-sg"
  vpc_id = module.vpc.vpc_id

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
}

resource "aws_security_group" "app_sg" {
  name = "app-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      security_groups = [aws_security_group.web_sg.id]
    }
    ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      security_groups = [aws_security_group.web_sg.id]
    }
    egress {
      from_port   = 0
      to_port     = 0 
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
} 

resource "aws_security_group" "rds_sg" {
  vpc_id = module.vpc.vpc_id
  ingress {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      security_groups = [aws_security_group.app_sg.id]
  }
}

#------------------- EC2 modules -------------------#

module "web" {
  source = "./modules/web"
  vpc_id = module.vpc.vpc_id
  subnet_id = module.vpc.public_subnet_ids[0]
  sg_id = aws_security_group.web_sg.id
  ami = "ami-0532be01f26a3de55"
  key_name = var.key_name
  name = "Web-Server "
}

module "app" {
  source = "./modules/web"
  vpc_id = module.vpc.vpc_id
  subnet_id = module.vpc.private_subnet_ids[0]
  sg_id = aws_security_group.app_sg.id
  ami = "ami-0532be01f26a3de55"
  key_name = var.key_name
  name = "App-Server "
}

#------------------- RDS module -------------------#


module "rds" {
  source = "./modules/rds"
  vpc_id = module.vpc.vpc_id  
  subnet_ids = module.vpc.private_subnet_ids
  sg_id = aws_security_group.rds_sg.id
}