# Terragrunt

P2P infra deployment repository 

## Usage

> This is for local development only.

### Installation

```bash
brew install terragrunt
```

### Terraform/Terragrunt Commands

Terragrunt is a wrapper around Terraform, so all Terraform commands work with Terragrunt.

```bash
terragrunt init
terragrunt plan
terragrunt apply
```

## Repository structure

```txt
.
├── .github
│   └── workflows
│       ├── aws_{account_name}.yaml
│  
├── modules
│   ├── aws
│   │   └── {owner}_{module_name}.hcl
├── aws
│   └── {account_name}
│       ├── {project_name}
│       │   ├── {region_name}
│       │   │   ├── {module_name}
│       │   │   │   └── terragrunt.hcl
│       │   │   └── region.hcl
│       │   └── project.hcl
│       └── account.hcl
└── terragrunt.hcl
```

## Resources deploying
1. VPC
    a. Subnets
    b. Route Tables
    d. Nat & IG Gateway
2. ECR
3. EKS
    a. Cluster
    b. Node Pool
4. ALB
    a. Target Groups
5. EC2
6. Autoscalling Ec2
7. Cloudfront
8. EFS
9. S3
10. RDS
11. ECS Cluster
12. ECS Services
    a. Frontend Test ECS
    b. Backend Test ECS
    c. ECS on EC2 Example
13. Security Groups
    a. EC2
    b. ALB
    c. ECS
14. IAM
    a. Policy
    b. Role
    c. IAM User
    d. OIDC Provider
    e. OIDC Role

## Future Scope 
Add examples of remaining AWS resources