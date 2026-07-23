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
# Application Load Balancer security group
# ---------------------------------------------------------

resource "aws_security_group" "alb" {
  name        = "${local.name_prefix}-alb-sg"
  description = "Controls inbound and outbound traffic for the public ALB"
  vpc_id      = var.vpc_id

  revoke_rules_on_delete = true

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-alb-sg"
      Tier = "ingress"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  for_each = var.enable_http ? toset(var.allowed_http_cidrs) : toset([])

  security_group_id = aws_security_group.alb.id

  description = "Allow HTTP traffic to the ALB"

  cidr_ipv4   = each.value
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  for_each = var.enable_https ? toset(var.allowed_https_cidrs) : toset([])

  security_group_id = aws_security_group.alb.id

  description = "Allow HTTPS traffic to the ALB"

  cidr_ipv4   = each.value
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

# ---------------------------------------------------------
# ECS task security group
# ---------------------------------------------------------

resource "aws_security_group" "ecs_tasks" {
  name        = "${local.name_prefix}-ecs-tasks-sg"
  description = "Controls traffic to ECS Fargate tasks"
  vpc_id      = var.vpc_id

  revoke_rules_on_delete = true

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-ecs-tasks-sg"
      Tier = "application"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "ecs_from_alb" {
  security_group_id = aws_security_group.ecs_tasks.id

  description = "Allow application traffic only from the ALB"

  referenced_security_group_id = aws_security_group.alb.id

  from_port   = var.application_port
  to_port     = var.application_port
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "alb_to_ecs" {
  security_group_id = aws_security_group.alb.id

  description = "Allow ALB traffic to ECS tasks"

  referenced_security_group_id = aws_security_group.ecs_tasks.id

  from_port   = var.application_port
  to_port     = var.application_port
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "ecs_https" {
  security_group_id = aws_security_group.ecs_tasks.id

  description = "Allow ECS tasks to access HTTPS services"

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "ecs_dns_udp" {
  security_group_id = aws_security_group.ecs_tasks.id

  description = "Allow DNS queries over UDP"

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 53
  to_port     = 53
  ip_protocol = "udp"
}

resource "aws_vpc_security_group_egress_rule" "ecs_dns_tcp" {
  security_group_id = aws_security_group.ecs_tasks.id

  description = "Allow DNS queries over TCP"

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 53
  to_port     = 53
  ip_protocol = "tcp"
}

# ---------------------------------------------------------
# Database security group
# ---------------------------------------------------------

resource "aws_security_group" "database" {
  count = var.enable_database_security_group ? 1 : 0

  name        = "${local.name_prefix}-database-sg"
  description = "Controls access to the relational database"
  vpc_id      = var.vpc_id

  revoke_rules_on_delete = true

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-database-sg"
      Tier = "database"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "database_from_ecs" {
  count = var.enable_database_security_group ? 1 : 0

  security_group_id = aws_security_group.database[0].id

  description = "Allow database connections only from ECS tasks"

  referenced_security_group_id = aws_security_group.ecs_tasks.id

  from_port   = var.database_port
  to_port     = var.database_port
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "ecs_to_database" {
  count = var.enable_database_security_group ? 1 : 0

  security_group_id = aws_security_group.ecs_tasks.id

  description = "Allow ECS tasks to access the database"

  referenced_security_group_id = aws_security_group.database[0].id

  from_port   = var.database_port
  to_port     = var.database_port
  ip_protocol = "tcp"
}

# ---------------------------------------------------------
# Redis security group
# ---------------------------------------------------------

resource "aws_security_group" "redis" {
  count = var.enable_redis_security_group ? 1 : 0

  name        = "${local.name_prefix}-redis-sg"
  description = "Controls access to Redis"
  vpc_id      = var.vpc_id

  revoke_rules_on_delete = true

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-redis-sg"
      Tier = "cache"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "redis_from_ecs" {
  count = var.enable_redis_security_group ? 1 : 0

  security_group_id = aws_security_group.redis[0].id

  description = "Allow Redis connections only from ECS tasks"

  referenced_security_group_id = aws_security_group.ecs_tasks.id

  from_port   = var.redis_port
  to_port     = var.redis_port
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "ecs_to_redis" {
  count = var.enable_redis_security_group ? 1 : 0

  security_group_id = aws_security_group.ecs_tasks.id

  description = "Allow ECS tasks to access Redis"

  referenced_security_group_id = aws_security_group.redis[0].id

  from_port   = var.redis_port
  to_port     = var.redis_port
  ip_protocol = "tcp"
}
