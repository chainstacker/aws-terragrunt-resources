# Terragrunt

This repository contains a collection of modular and reusable Terragrunt configurations for deploying and managing a wide range of AWS resources. It simplifies the management of infrastructure as code (IaC) by leveraging Terragrunt to enhance Terraform's capabilities, including state management and module composition.

### Features
Comprehensive Resource Coverage: Includes VPC, EKS, ECS, ALB, RDS, EC2, CloudFront, and more.
Modular Structure: Each resource is encapsulated in its own module, allowing for easy reuse and customization.
Scalability and Automation: Supports scalable and automated infrastructure deployment.
Best Practices: Follows AWS and IaC best practices for security, reliability, and maintainability.

### Use Cases
Provisioning cloud resources for production-ready environments.
Setting up scalable Kubernetes clusters using Amazon EKS.
Managing multi-tier applications with ALB, ECS, and RDS.
Automating CI/CD pipelines with ECR, EC2, and S3 integrations.
Building secure and highly available architectures.

## Usage

This repository is designed to deploy and manage various AWS resources using **Terragrunt**. Terragrunt is a wrapper around Terraform, so all Terraform commands work with Terragrunt. Below are the steps to utilize this repository effectively:

### Prerequisites
1. **Install Terraform**  
   Ensure Terraform is installed. Follow the [official documentation](https://developer.hashicorp.com/terraform/downloads) to set it up.
   
2. **Install Terragrunt**  
   Install Terragrunt, which simplifies working with Terraform. Refer to the [Terragrunt installation guide](https://terragrunt.gruntwork.io/docs/getting-started/install/).

3. **AWS CLI**  
   Install and configure the AWS CLI with appropriate credentials. Refer to the [AWS CLI setup guide](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html).

4. **Access to Terraform Backend (if applicable)**  
   Ensure access to the S3 bucket or other backends used to store Terraform state.

---

### Steps to Use
1. **Clone the Repository**
```bash
   git clone https://github.com/shashwat0309/aws-terragrunt-resources.git
   cd aws-terragrunt-resources
```

2. **Configure AWS Provider**
Update your AWS profile and region in the terragrunt.hcl files (if not already set). Example:
```hcl
remote_state {
  backend = "s3"
  config = {
    encrypt = true
    bucket  = "Enter_Your_Terraform_State_Bucket"
    region  = local.region
    key = "${path_relative_to_include()}/terraform.tfstate"
    dynamodb_table = "Enter_Your_Terraform_DynamoDB_Table"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}
```

3. **Initialize Terragrunt** Navigate to the directory containing the terragrunt.hcl file for the resource you wish to deploy. Run:

```hcl
terragrunt init
```

4. **Plan the Deployment**
Review the changes to be applied by running:

```hcl
terragrunt plan
```

5. **Apply the Changes**
Deploy the resources by running:

```hcl
terragrunt apply
```

6. **Destroy the Resources**
To clean up the resources, use:
```hcl
terragrunt destroy
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