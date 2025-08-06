output "instance_public_ips" {
  description = "Public IPs of the two EC2 instances"
  value       = aws_instance.app_instance[*].public_ip
}
