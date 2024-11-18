include {
  path = find_in_parent_folders()
}

include "vpc" {
  path = "${get_repo_root()}/modules/terraform-aws-modules_vpc.hcl"
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


inputs = {
  name            = "${local.locals.project_name}-${local.locals.environment_name}-vpc"
  cidr            = "10.9.0.0/16"
  azs             = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  private_subnets = ["10.9.3.0/24", "10.9.4.0/24", "10.9.5.0/24"]
  private_subnet_names = [ "${local.locals.project_name}-${local.locals.environment_name}-privateA-subnet", "${local.locals.project_name}-${local.locals.environment_name}-privateB-subnet", "${local.locals.project_name}-${local.locals.environment_name}-privateC-subnet" ]

  public_subnets  = ["10.9.0.0/24", "10.9.1.0/24", "10.9.2.0/24"]
  public_subnet_names = [ "${local.locals.project_name}-${local.locals.environment_name}-public-subnet", "${local.locals.project_name}-${local.locals.environment_name}-public-subnet", "${local.locals.project_name}-${local.locals.environment_name}-public-subnet" ]

  enable_dns_hostnames = true
  enable_dns_support = true
  map_public_ip_on_launch = true
  enable_nat_gateway = true
  enable_vpn_gateway = false
  enable_ipv6        = false
  single_nat_gateway = true
  one_nat_gateway_per_az = false
  manage_default_network_acl = false
  manage_default_route_table = false
  manage_default_security_group = false

  tags = {
    Terraform   = "true"
    Environment = "${local.locals.environment_name}"
    Project     = "${local.locals.project_name}"
    ProjectCode = "${local.locals.project_code}"
  }
}
