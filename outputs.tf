# -----------------------------------------------
# outputs.tf — Output Values
# -----------------------------------------------

output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.apache_ec2.id
}

output "instance_public_ip" {
  description = "EC2 Public IP Address"
  value       = aws_instance.apache_ec2.public_ip
}

output "apache_url" {
  description = "Apache Web Server URL"
  value       = "http://${aws_instance.apache_ec2.public_ip}"
}

output "ip_file_location" {
  description = "Local file where IP address is saved"
  value       = "${path.module}/ec2_ip_address.txt"
}
