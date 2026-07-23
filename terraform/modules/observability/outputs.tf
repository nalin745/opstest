

output "dashboard_name" {
  description = "CloudWatch operations dashboard name."
  value       = aws_cloudwatch_dashboard.application.dashboard_name
}

output "alarm_names" {
  description = "Names of the CloudWatch alarms."
  value = [
    aws_cloudwatch_metric_alarm.ecs_cpu_high.alarm_name,
    aws_cloudwatch_metric_alarm.ecs_memory_high.alarm_name,
    aws_cloudwatch_metric_alarm.target_5xx_high.alarm_name,
    aws_cloudwatch_metric_alarm.response_time_high.alarm_name,
    aws_cloudwatch_metric_alarm.healthy_hosts_low.alarm_name,
    aws_cloudwatch_metric_alarm.rejected_connections.alarm_name,
    aws_cloudwatch_metric_alarm.application_errors.alarm_name,
  ]
}
