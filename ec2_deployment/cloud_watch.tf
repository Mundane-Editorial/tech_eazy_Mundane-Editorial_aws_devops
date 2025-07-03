resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/app/logs"
  retention_in_days = 7
}

resource "aws_sns_topic" "app_alerts" {
  name = "app-alerts-topic"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.app_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_log_metric_filter" "error_filter" {
  name           = "error-metric-filter"
  log_group_name = aws_cloudwatch_log_group.app_logs.name
  pattern        = "ERROR || Exception"
  metric_transformation {
    name      = "ErrorCount"
    namespace = "App"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "error_alarm" {
  alarm_name          = "app-error-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.error_filter.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.error_filter.metric_transformation[0].namespace
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm if application log contains ERROR or Exception"
  alarm_actions       = [aws_sns_topic.app_alerts.arn]
}

resource "aws_iam_policy" "cw_agent_policy" {
  name = "cw-agent-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cw_agent_policy_attachment" {
  role       = aws_iam_instance_profile.Java-Application-Profile.name
  policy_arn = aws_iam_policy.cw_agent_policy.arn
} 