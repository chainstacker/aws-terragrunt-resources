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
## Resources Deployed

### 1. Virtual Private Cloud (VPC)
- Subnets
- Route Tables
- NAT Gateway
- Internet Gateway

### 2. Elastic Container Registry (ECR)

### 3. Elastic Kubernetes Service (EKS)
- Cluster
- Node Pool

### 4. Application Load Balancer (ALB)
- Target Groups

### 5. Elastic Compute Cloud (EC2)

### 6. Auto Scaling for EC2

### 7. Amazon CloudFront

### 8. Elastic File System (EFS)

### 9. Simple Storage Service (S3)

### 10. Relational Database Service (RDS)

### 11. Elastic Container Service (ECS)
- ECS Cluster
- ECS Services:
  - Frontend Test ECS
  - Backend Test ECS
  - ECS on EC2 Example

### 12. Security Groups
- EC2
- ALB
- ECS

### 13. Identity and Access Management (IAM)
- Policies
- Roles
- IAM Users
- OIDC Provider
- OIDC Roles

## Future Scope 
Add examples of remaining AWS resources