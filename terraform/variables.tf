variable "region" {
  default = "ap-south-1"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  description = "SSH key pair"
  type        = string
}

variable "app_ami" {
  default = "ami-0f918f7e67a3323f0" 
}
