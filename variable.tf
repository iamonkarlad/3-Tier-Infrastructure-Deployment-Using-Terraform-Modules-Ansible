variable "private_subnet_cidrs" {
  type = list(string)
  default = ["10.0.16.0/20", "10.0.32.0/20"]
}

variable "key_name" {
  default = "linux-server-key"
}
