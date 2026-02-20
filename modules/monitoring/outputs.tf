output "sns_topic_arn" { value = aws_sns_topic.arcanum_sns_topic01.arn }
output "log_group_name" { value = aws_cloudwatch_log_group.arcanum_log_group01.name }