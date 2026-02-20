# outputs.tf (ROOT)

output "ec2_instance_id" {
  value = module.app_ec2.instance_id
}

output "ec2_public_ip" {
  value = module.app_ec2.public_ip
}

output "ec2_public_dns" {
  value = module.app_ec2.public_dns
}

output "db_identifier" {
  value = module.database.db_identifier
}

output "db_endpoint" {
  value = module.database.db_endpoint
}

output "db_secret_name" {
  value = module.database.secret_name
}

output "db_secret_arn" {
  value = module.database.secret_arn
}