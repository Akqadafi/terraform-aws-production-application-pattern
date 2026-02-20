output "db_endpoint" { value = aws_db_instance.arcanum_rds01.address }
output "db_port" { value = aws_db_instance.arcanum_rds01.port }
output "db_identifier" { value = aws_db_instance.arcanum_rds01.identifier }

output "secret_arn" { value = aws_secretsmanager_secret.arcanum_db_secret01.arn }
output "secret_name" { value = aws_secretsmanager_secret.arcanum_db_secret01.name }