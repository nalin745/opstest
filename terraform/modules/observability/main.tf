locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.common_tags
  )

}

# ---------------------------------------------------------
# ECS CPU alarm
# ---------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  alarm_name = "${local.name_prefix}-ecs-cpu-high"

  alarm_description = (
    "ECS service average CPU utilization exceeded ${var.cpu_alarm_threshold}%."
  )

  namespace   = "AWS/ECS"
  metric_name = "CPUUtilization"

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }

  comparison_operator = "GreaterThanOrEqualToThreshold"
  statistic           = "Average"

  period              = var.alarm_period_seconds
  evaluation_periods  = var.alarm_evaluation_periods
  datapoints_to_alarm = var.alarm_evaluation_periods

  threshold = var.cpu_alarm_threshold

  treat_missing_data = "notBreaching"

  insufficient_data_actions = []

  tags = local.common_tags
}

# ---------------------------------------------------------
# ECS memory alarm
# ---------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "ecs_memory_high" {
  alarm_name = "${local.name_prefix}-ecs-memory-high"

  alarm_description = (
    "ECS service average memory utilization exceeded ${var.memory_alarm_threshold}%."
  )

  namespace   = "AWS/ECS"
  metric_name = "MemoryUtilization"

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }

  comparison_operator = "GreaterThanOrEqualToThreshold"
  statistic           = "Average"

  period              = var.alarm_period_seconds
  evaluation_periods  = var.alarm_evaluation_periods
  datapoints_to_alarm = var.alarm_evaluation_periods

  threshold = var.memory_alarm_threshold

  treat_missing_data = "notBreaching"

  insufficient_data_actions = []

  tags = local.common_tags
}

# ---------------------------------------------------------
# ALB target 5XX alarm
# ---------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "target_5xx_high" {
  alarm_name = "${local.name_prefix}-target-5xx-high"

  alarm_description = (
    "Application targets returned at least ${var.target_5xx_threshold} HTTP 5XX responses."
  )

  namespace   = "AWS/ApplicationELB"
  metric_name = "HTTPCode_Target_5XX_Count"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }

  comparison_operator = "GreaterThanOrEqualToThreshold"
  statistic           = "Sum"

  period              = var.alarm_period_seconds
  evaluation_periods  = 1
  datapoints_to_alarm = 1

  threshold = var.target_5xx_threshold

  treat_missing_data = "notBreaching"

  insufficient_data_actions = []

  tags = local.common_tags
}

# ---------------------------------------------------------
# ALB response-time alarm
# ---------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "response_time_high" {
  alarm_name = "${local.name_prefix}-response-time-high"

  alarm_description = (
    "Average ALB target response time exceeded ${var.response_time_threshold_seconds} seconds."
  )

  namespace   = "AWS/ApplicationELB"
  metric_name = "TargetResponseTime"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }

  comparison_operator = "GreaterThanOrEqualToThreshold"
  statistic           = "Average"

  period              = var.alarm_period_seconds
  evaluation_periods  = var.alarm_evaluation_periods
  datapoints_to_alarm = var.alarm_evaluation_periods

  threshold = var.response_time_threshold_seconds

  treat_missing_data = "notBreaching"

  insufficient_data_actions = []

  tags = local.common_tags
}

# ---------------------------------------------------------
# Healthy-target alarm
# ---------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "healthy_hosts_low" {
  alarm_name = "${local.name_prefix}-healthy-hosts-low"

  alarm_description = (
    "The number of healthy application targets fell below ${var.minimum_healthy_host_count}."
  )

  namespace   = "AWS/ApplicationELB"
  metric_name = "HealthyHostCount"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }

  comparison_operator = "LessThanThreshold"
  statistic           = "Minimum"

  period              = var.alarm_period_seconds
  evaluation_periods  = 2
  datapoints_to_alarm = 2

  threshold = var.minimum_healthy_host_count

  treat_missing_data = "breaching"

  insufficient_data_actions = []

  tags = local.common_tags
}

# ---------------------------------------------------------
# ALB rejected connections
# ---------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "rejected_connections" {
  alarm_name = "${local.name_prefix}-alb-rejected-connections"

  alarm_description = (
    "The ALB rejected connections because it reached a limit."
  )

  namespace   = "AWS/ApplicationELB"
  metric_name = "RejectedConnectionCount"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  comparison_operator = "GreaterThanThreshold"
  statistic           = "Sum"

  period              = var.alarm_period_seconds
  evaluation_periods  = 1
  datapoints_to_alarm = 1

  threshold = 0

  treat_missing_data = "notBreaching"

  insufficient_data_actions = []

  tags = local.common_tags
}

# ---------------------------------------------------------
# CloudWatch Logs metric filter for application errors
# ---------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "application_errors" {
  alarm_name = "${local.name_prefix}-application-errors"

  alarm_description = (
    "The application emitted one or more ERROR-level logs."
  )

  namespace   = "${var.project_name}/${var.environment}"
  metric_name = "ApplicationErrorCount"

  comparison_operator = "GreaterThanOrEqualToThreshold"
  statistic           = "Sum"

  period              = var.alarm_period_seconds
  evaluation_periods  = 1
  datapoints_to_alarm = 1

  threshold = 1

  treat_missing_data = "notBreaching"

  insufficient_data_actions = []

  tags = local.common_tags
}


# ---------------------------------------------------------
# CloudWatch operational dashboard
# ---------------------------------------------------------

resource "aws_cloudwatch_dashboard" "application" {
  dashboard_name = "${local.name_prefix}-operations"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "text"
        x      = 0
        y      = 0
        width  = 24
        height = 2

        properties = {
          markdown = join("\n", [
            "# ${var.project_name} — ${var.environment}",
            "ECS service, ALB and application operational dashboard.",
          ])
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 2
        width  = 12
        height = 6

        properties = {
          title  = "ECS CPU and memory utilization"
          region = var.aws_region
          period = 60
          stat   = "Average"

          metrics = [
            [
              "AWS/ECS",
              "CPUUtilization",
              "ClusterName",
              var.ecs_cluster_name,
              "ServiceName",
              var.ecs_service_name,
              {
                label = "CPU utilization"
              }
            ],
            [
              ".",
              "MemoryUtilization",
              ".",
              ".",
              ".",
              ".",
              {
                label = "Memory utilization"
              }
            ]
          ]

          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 2
        width  = 12
        height = 6

        properties = {
          title  = "ALB requests and target response time"
          region = var.aws_region
          period = 60
          stat   = "Average"

          metrics = [
            [
              "AWS/ApplicationELB",
              "RequestCount",
              "LoadBalancer",
              var.alb_arn_suffix,
              {
                stat  = "Sum"
                label = "Requests"
              }
            ],
            [
              "AWS/ApplicationELB",
              "TargetResponseTime",
              "LoadBalancer",
              var.alb_arn_suffix,
              "TargetGroup",
              var.target_group_arn_suffix,
              {
                label = "Response time"
                yAxis = "right"
              }
            ]
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 8
        width  = 12
        height = 6

        properties = {
          title  = "ALB target HTTP status codes"
          region = var.aws_region
          period = 60
          stat   = "Sum"

          metrics = [
            [
              "AWS/ApplicationELB",
              "HTTPCode_Target_2XX_Count",
              "LoadBalancer",
              var.alb_arn_suffix,
              "TargetGroup",
              var.target_group_arn_suffix,
              {
                label = "2XX"
              }
            ],
            [
              ".",
              "HTTPCode_Target_4XX_Count",
              ".",
              ".",
              ".",
              ".",
              {
                label = "4XX"
              }
            ],
            [
              ".",
              "HTTPCode_Target_5XX_Count",
              ".",
              ".",
              ".",
              ".",
              {
                label = "5XX"
              }
            ]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 8
        width  = 12
        height = 6

        properties = {
          title  = "ALB target health"
          region = var.aws_region
          period = 60
          stat   = "Minimum"

          metrics = [
            [
              "AWS/ApplicationELB",
              "HealthyHostCount",
              "LoadBalancer",
              var.alb_arn_suffix,
              "TargetGroup",
              var.target_group_arn_suffix,
              {
                label = "Healthy targets"
              }
            ],
            [
              ".",
              "UnHealthyHostCount",
              ".",
              ".",
              ".",
              ".",
              {
                label = "Unhealthy targets"
              }
            ]
          ]

          yAxis = {
            left = {
              min = 0
            }
          }
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 14
        width  = 12
        height = 6

        properties = {
          title  = "Application ERROR logs"
          region = var.aws_region
          period = 60
          stat   = "Sum"

          metrics = [
            [
              "${var.project_name}/${var.environment}",
              "ApplicationErrorCount",
              {
                label = "Application errors"
              }
            ]
          ]

          yAxis = {
            left = {
              min = 0
            }
          }
        }
      },
      {
        type   = "log"
        x      = 12
        y      = 14
        width  = 12
        height = 6

        properties = {
          title  = "Recent application errors"
          region = var.aws_region

          query = join("\n", [
            "SOURCE '${var.application_log_group_name}'",
            "| fields @timestamp, level, message, request_id, path, status_code, duration_ms",
            "| filter level = \"ERROR\" or status_code >= 500",
            "| sort @timestamp desc",
            "| limit 20"
          ])

          view = "table"
        }
      }
    ]
  })
}
