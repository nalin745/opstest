data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

module "networking" {
  source = "../../modules/networking"

  project_name = var.project_name
  environment  = var.environment

  vpc_cidr = var.vpc_cidr

  availability_zones = var.availability_zones

  public_subnet_cidrs = var.public_subnet_cidrs

  private_app_subnet_cidrs = var.private_app_subnet_cidrs

  private_db_subnet_cidrs = var.private_db_subnet_cidrs

  enable_nat_gateway = true

  # Development uses one shared NAT Gateway to reduce cost.
  single_nat_gateway = true

  enable_flow_logs        = true
  flow_log_retention_days = 30

  common_tags = {
    Owner      = "Nalin Ranasinghe"
    Assessment = "Senior DevOps Engineer"
    CostCentre = "InterviewAssessment"
  }
}

module "security" {
  source = "../../modules/security"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.networking.vpc_id

  application_port = var.application_port

  enable_http  = true
  enable_https = false

  enable_database_security_group = true
  enable_redis_security_group    = false

  common_tags = {
    Owner      = "Nalin Ranasinghe"
    Assessment = "Senior DevOps Engineer"
  }
}

module "ecr" {
  source = "../../modules/ecr"

  project_name    = var.project_name
  environment     = var.environment
  repository_name = "application"

  image_tag_mutability = "IMMUTABLE"
  scan_on_push         = true

  force_delete = false

  common_tags = {
    Owner      = "Nalin Ranasinghe"
    Assessment = "Senior DevOps Engineer"
  }
}

module "ecs_cluster" {
  source = "../../modules/ecs-cluster"

  project_name = var.project_name
  environment  = var.environment

  enable_container_insights = true
  enable_execute_command    = true

  # Cost-optimized development configuration.
  fargate_base        = 0
  fargate_weight      = 1
  fargate_spot_weight = 2

  common_tags = {
    Owner      = "Nalin Ranasinghe"
    Assessment = "Senior DevOps Engineer"
  }
}

module "alb" {
  source = "../../modules/alb"

  project_name = var.project_name
  environment  = var.environment

  vpc_id            = module.networking.vpc_id
  public_subnet_ids = module.networking.public_subnet_ids

  alb_security_group_id = module.security.alb_security_group_id

  application_port  = var.application_port
  health_check_path = var.health_check_path

  # Development uses HTTP until a domain and ACM certificate are available.
  certificate_arn = null

  enable_deletion_protection = false

  common_tags = {
    Owner      = "Nalin Ranasinghe"
    Assessment = "Senior DevOps Engineer"
  }
}

module "ecs_service" {
  source = "../../modules/ecs-service"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region

  cluster_id   = module.ecs_cluster.cluster_id
  cluster_name = module.ecs_cluster.cluster_name

  private_subnet_ids = module.networking.private_app_subnet_ids

  ecs_tasks_security_group_id = (
    module.security.ecs_tasks_security_group_id
  )

  target_group_arn   = module.alb.target_group_arn
  ecr_repository_arn = module.ecr.repository_arn

  image_uri           = var.application_image_uri
  application_version = var.application_version

  container_name = "application"
  container_port = var.application_port

  task_cpu    = 512
  task_memory = 1024

  desired_count      = var.desired_task_count
  minimum_task_count = 1
  maximum_task_count = 4

  cpu_scaling_target    = 60
  memory_scaling_target = 70

  scale_out_cooldown = 60
  scale_in_cooldown  = 300

  health_check_grace_period_seconds = 90

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  log_retention_days = 30

  enable_readonly_root_filesystem = true
  enable_execute_command          = false

  # Keep the first task on standard Fargate.
  fargate_base   = 1
  fargate_weight = 1

  # Development starts with no Spot because desired_count is one.
  # Increase this after testing with two or more tasks.
  fargate_spot_weight = 0

  environment_variables = {
    APP_ENV     = "development"
    LOG_LEVEL   = "INFO"
    ENABLE_DOCS = "true"
  }

  secretsmanager_secrets = {}
  ssm_parameters         = {}
  kms_key_arns           = []

  common_tags = {
    Owner      = "Nalin Ranasinghe"
    Assessment = "Senior DevOps Engineer"
  }

  # Ensures the listener and target group are created before the service.
  depends_on = [
    module.alb
  ]
}

module "github_oidc" {
  source = "../../modules/github-oidc"

  project_name = var.project_name
  environment  = var.environment

  aws_account_id = data.aws_caller_identity.current.account_id
  aws_region     = var.aws_region

  github_owner            = var.github_owner
  github_repository       = var.github_repository
  github_environment_name = var.github_environment_name

  create_oidc_provider       = var.create_github_oidc_provider
  existing_oidc_provider_arn = var.existing_github_oidc_provider_arn

  ecr_repository_arn = module.ecr.repository_arn

  ecs_cluster_arn = module.ecs_cluster.cluster_arn
  ecs_service_arn = module.ecs_service.service_arn

  task_definition_family = (
    module.ecs_service.task_definition_family
  )

  task_execution_role_arn = (
    module.ecs_service.task_execution_role_arn
  )

  task_role_arn = module.ecs_service.task_role_arn

  common_tags = {
    Owner      = "Nalin Ranasinghe"
    Assessment = "Senior DevOps Engineer"
  }

  depends_on = [
    module.ecs_service
  ]
}