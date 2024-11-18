include {
  path = find_in_parent_folders()
}

include "alb" {
  path = "${get_repo_root()}/modules/aws/terraform-aws-modules_alb.hcl"
}

locals {
  account_locals = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  region_locals  = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals
  env_locals     = read_terragrunt_config(find_in_parent_folders("environment.hcl")).locals
  project_locals = read_terragrunt_config(find_in_parent_folders("project.hcl")).locals
  module_locals  = try(read_terragrunt_config("module.hcl").locals, {})
  locals = merge(
    local.account_locals,
    local.region_locals,
    local.project_locals,
    local.env_locals,
    local.module_locals
  )
}

dependency "vpc" {
  config_path                             = "../vpc"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs = {
    vpc_id = "vpc-012341a0dd8b01234"
    public_subnets = [
      "subnet-003601fe683fd1113",
      "subnet-0f0787cffc6ae1113",
      "subnet-00e05034aa90b1113"
    ],
    private_subnets = [
      "subnet-003601fe683fd1111",
      "subnet-0f0787cffc6ae1112",
      "subnet-00e05034aa90b1112"
    ],
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "sg_alb" {
  config_path                             = "../security_groups/alb"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs = {
    security_group_id = "sg-02092eea015a2eade"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

inputs = {
  name                             = "${local.locals.project_name}-${local.locals.environment_name}-alb"
  vpc_id                           = dependency.vpc.outputs.vpc_id
  load_balancer_type               = "application"
  internal                         = false
  drop_invalid_header_fields       = true
  enable_cross_zone_load_balancing = true

  subnets         = dependency.vpc.outputs.public_subnets
  security_groups = [dependency.sg_alb.outputs.security_group_id]

  target_groups = [
    {
      name                 = "test-app-backend-app-tg"
      backend_protocol     = "HTTP"
      backend_port         = 80
      target_type          = "ip"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        path                = "/api/v1/health-check"
        interval            = 30
        healthy_threshold   = 5
        unhealthy_threshold = 5
        timeout             = 10
        protocol            = "HTTP"
        matcher             = "200-399"
      }
    },
    {
      name                 = "test-app-frontend-app-tg"
      backend_protocol     = "HTTP"
      backend_port         = 80
      target_type          = "ip"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        path                = "/health"
        interval            = 30
        healthy_threshold   = 5
        unhealthy_threshold = 5
        timeout             = 10
        protocol            = "HTTP"
        matcher             = "200-399"
      }
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]
  http_tcp_listener_rules = []

  https_listeners = [
    {
      port            = "443"
      protocol        = "HTTPS"
      ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"
      certificate_arn = "arn:aws:acm:eu-central-1:654854536451:certificate/15474547-3574-4a8c-8bd8-a146777b7569" # Paste your certificate ARN
      action_type     = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = "Moved"
        status_code  = "503"
      }
    }
  ]
  https_listener_rules = [
    {
      priority             = 200
      https_listener_index = 0

      actions = [
        {
          type               = "forward"
          target_group_index = 0

        }
      ]
      conditions = [
        {
          host_headers = ["test-app-backend.com"]
        }
      ]
    },
    {
      priority             = 300
      https_listener_index = 0
      target_group_index   = 1
      actions = [
        {
          type               = "forward"
          target_group_index = 1

        }
      ]
      conditions = [
        {
          host_headers = ["test-app-frontend.com"]
        }
      ]
    }
  ]


   tags = {
    Terraform   = "true"
    Environment = "${local.locals.environment_name}"
    Project     = "${local.locals.project_name}"
    ProjectCode = "${local.locals.project_id}"
  }
}
