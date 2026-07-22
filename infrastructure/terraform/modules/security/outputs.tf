output "ec2_security_group_id" {
  description = "ID del security group para EC2."
  value       = aws_security_group.ec2.id
}

output "rds_security_group_id" {
  description = "ID del security group para RDS."
  value       = aws_security_group.rds.id
}
