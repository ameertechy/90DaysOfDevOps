output "instance_ids" {
  description = "IDs of the EC2 instances"
  value       = aws_instance.web[*].id
}

output "instance_public_ips" {
  description = "Public IPs"
  value       = aws_instance.web[*].public_ip
}

output "instance_public_dns" {
  description = "Public DNS names"
  value       = aws_instance.web[*].public_dns
}

output "security_group_id" {
  description = "SG ID"
  value       = aws_security_group.web.id
}

output "ami_id" {
  description = "Resolved Amazon Linux 2 AMI"
  value       = data.aws_ami.amazon_linux.id
}