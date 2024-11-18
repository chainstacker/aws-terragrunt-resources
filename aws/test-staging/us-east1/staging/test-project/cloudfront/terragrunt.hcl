include {
  path = find_in_parent_folders()
}

include "cloudfront" {
  path = "${get_repo_root()}/modules/terraform-aws-modules_cloudfront.hcl"
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
  enabled              = true
  is_ipv6_enabled      = true
  comment              = "Cloudfront of test app"
  http_version         = "http2"
  price_class          = "PriceClass_100"
  aliases              = ["test-app.dev"]
  geo_restriction_type = "none"
  default_root_object  = "index.html"
  origin = {
    "test-app.us-east-2.amazonaws.com" = {
      domain_name = "test-app.s3.us-east-2.amazonaws.com"
    }
  }
  default_cache_behavior = {
    target_origin_id       = "test-app.us-east-2.amazonaws.com"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods         = ["HEAD", "GET", "OPTIONS"]
    query_string           = false

  }
  viewer_certificate = {
    acm_certificate_arn      = "arn:aws:acm:us-east-1:59956434332950:certificate/24415879-b2c3-4ab0-b317-fac343415123634"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"

  }


}
