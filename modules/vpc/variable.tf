variable "region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
}

variable "public_subnet" {
  type = list(string)
}

variable "private_subnet" {
  type = list(string)
}
variable "az" {
  type = list(string)
}


