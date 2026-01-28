variable "ami" {
  default = "ami-0532be01f26a3de55"
}

variable "key_name" {
 default = "linux-server-key" 
}
variable "instance_type" {
  default = "t2.micro"
}
variable "subnet_id" {}
variable "sg_id" {}
variable "name" {}


variable "vpc_id" {
  
}