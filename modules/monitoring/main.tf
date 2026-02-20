resource "aws_cloudwatch_log_group" "arcanum_log_group01" {
  name              = "/aws/ec2/${var.name_prefix}-rds-app"
  retention_in_days = 7

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-log-group01"
  })
}

resource "aws_sns_topic" "arcanum_sns_topic01" {
  name = "${var.name_prefix}-db-incidents"
}

resource "aws_sns_topic_subscription" "arcanum_sns_sub01" {
  topic_arn = aws_sns_topic.arcanum_sns_topic01.arn
  protocol  = "email"
  endpoint  = var.sns_email_endpoint
}

resource "aws_cloudwatch_metric_alarm" "arcanum_db_alarm01" {
  alarm_name          = "${var.name_prefix}-db-connection-failure"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "DBConnectionErrors"
  namespace           = "Lab/RDSApp"
  period              = 300
  statistic           = "Sum"
  threshold           = 3

  alarm_actions = [aws_sns_topic.arcanum_sns_topic01.arn]

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-alarm-db-fail"
  })
}