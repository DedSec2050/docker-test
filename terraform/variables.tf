variable "region" {
  default = "ap-south-1"
}

variable "app_ami" {
  description = "AMI ID for EC2 (if used)"
  default     = "ami-1234567890abcdef0"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  default = "your-ec2-keypair"
}