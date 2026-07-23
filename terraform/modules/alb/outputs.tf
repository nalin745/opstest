output "load_balancer_arn" {
  description = "ARN of the Application Load Balancer."
  value       = aws_lb.main.arn
}

output "load_balancer_dns_name" {
  description = "DNS name used to access the ALB."
  value       = aws_lb.main.dns_name
}

output "load_balancer_zone_id" {
  description = "Hosted-zone ID of the ALB."
  value       = aws_lb.main.zone_id
}

output "target_group_arn" {
  description = "ARN of the application target group."
  value       = aws_lb_target_group.application.arn
}

output "http_listener_arn" {
  description = "ARN of the HTTP listener."
  value = try(
    aws_lb_listener.http_forward[0].arn,
    aws_lb_listener.http_redirect[0].arn,
    null
  )
}

output "https_listener_arn" {
  description = "ARN of the HTTPS listener."
  value       = try(aws_lb_listener.https[0].arn, null)
}


output "load_balancer_arn_suffix" {
  description = "ALB ARN suffix used by CloudWatch metrics."
  value       = aws_lb.main.arn_suffix
}

output "target_group_arn_suffix" {
  description = "Target-group ARN suffix used by CloudWatch metrics."
  value       = aws_lb_target_group.application.arn_suffix
}