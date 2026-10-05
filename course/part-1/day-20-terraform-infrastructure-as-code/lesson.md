# Day 20 — Infrastructure as Code with Terraform

> **FOMA · William Foma**  
> **DEVOPS FROM ZERO TO PRODUCTION**  
> Define infrastructure as code, review the plan, then apply it safely.

---

## 1. Learning objectives

By the end of this lesson you should be able to:

- explain Infrastructure as Code;
- explain Terraform's declarative model;
- define providers, resources, variables, outputs and modules;
- understand Terraform state;
- use init, fmt, validate, plan, apply and destroy;
- explain drift and remote state;
- protect infrastructure credentials and state;
- connect Terraform to CI/CD.

---

## 2. Why Infrastructure as Code?

Manual infrastructure often looks like:

~~~text
Click console
   ↓
Create network
   ↓
Create subnet
   ↓
Create server
   ↓
Configure security
   ↓
Repeat for staging
   ↓
Repeat for production
~~~

The problem is reproducibility.

### Definition

**Infrastructure as Code (IaC)** means defining infrastructure in machine-readable configuration so it can be reviewed, versioned and reproduced.

### Analogy: building blueprint

A blueprint describes how a building should be constructed.

Terraform configuration plays a similar role for infrastructure.

---

## 3. What is Terraform?

### Definition

**Terraform** is a declarative Infrastructure as Code tool.

You describe the desired infrastructure.

Terraform calculates the changes required to move the environment toward that desired state.

### Mental model

~~~text
Configuration
     |
     v
Terraform
     |
     v
Provider/API
     |
     v
Real infrastructure
~~~

---

## 4. Declarative vs imperative

Imperative:

~~~text
1. Create network
2. Create subnet
3. Create server
4. Attach server
~~~

Declarative:

~~~text
I want:
- a network
- a subnet
- a server
- these relationships
~~~

### Analogy

Imperative is giving a taxi driver every turn.

Declarative is giving the destination and letting the route planner calculate the route.

---

## 5. Provider

### Definition

A **provider** connects Terraform to a platform or service.

Examples:

- AWS;
- Azure;
- Google Cloud;
- Kubernetes;
- GitHub.

Example:

~~~hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
~~~

Provider versions should be controlled deliberately.

---

## 6. Resource

### Definition

A **resource** represents an infrastructure object Terraform manages.

Example:

~~~hcl
resource "aws_s3_bucket" "artifacts" {
  bucket = "foma-example-artifacts"
}
~~~

Resource type: aws_s3_bucket.

Local name: artifacts.

---

## 7. Variables

### Definition

A **variable** lets configuration accept reusable inputs.

~~~hcl
variable "aws_region" {
  type    = string
  default = "ap-southeast-1"
}
~~~

Use:

~~~hcl
provider "aws" {
  region = var.aws_region
}
~~~

### Analogy

A machine has adjustable settings.

The machine stays the same while the setting changes.

---

## 8. Outputs

### Definition

An **output** exposes useful information after Terraform creates or reads infrastructure.

~~~hcl
output "bucket_name" {
  value = aws_s3_bucket.artifacts.id
}
~~~

Outputs are useful to humans, scripts and other modules.

---

## 9. Terraform state

### Definition

**Terraform state** records information Terraform uses to understand managed infrastructure.

Mental model:

~~~text
Configuration
     |
     v
Desired state

Terraform state
     |
     v
Known managed objects

Provider/API
     |
     v
Real infrastructure
~~~

### Critical lesson

State can contain sensitive information.

Protect it with controlled access and an appropriate backend.

Do not casually delete state.

---

## 10. terraform init

~~~bash
terraform init
~~~

### Meaning

Initialize the Terraform working directory and obtain required providers/modules.

Think:

> Prepare this project.

---

## 11. terraform fmt

~~~bash
terraform fmt
~~~

Formats Terraform files consistently.

Use it locally and in CI.

---

## 12. terraform validate

~~~bash
terraform validate
~~~

Checks whether the configuration is structurally valid.

It does not prove that the infrastructure design is correct.

---

## 13. terraform plan

~~~bash
terraform plan
~~~

### Definition

Plan previews proposed infrastructure changes.

Mental model:

~~~text
Code
  |
  v
Plan
  |
  v
Review
  |
  v
Apply
~~~

### Analogy

Before construction starts, you review the construction plan.

---

## 14. terraform apply

~~~bash
terraform apply
~~~

Apply executes the proposed changes.

A strong workflow is:

~~~text
fmt
 ↓
validate
 ↓
plan
 ↓
review
 ↓
apply
 ↓
verify
~~~

---

## 15. terraform destroy

~~~bash
terraform destroy
~~~

### Definition

Destroy removes infrastructure managed by the configuration.

This is destructive.

Use it only when you understand what will be removed.

For learning, use disposable infrastructure.

---

## 16. Drift

### Definition

**Drift** occurs when actual infrastructure differs from the configuration/state Terraform expects.

Example:

~~~text
Terraform:
versioning enabled

Manual change:
versioning disabled

        ↓
       DRIFT
~~~

If Terraform manages a resource, prefer changing it through Terraform.

---

## 17. Modules

### Definition

A **module** is reusable Terraform configuration.

Instead of repeatedly defining:

~~~text
VPC
subnets
routes
security
~~~

you can package the pattern into a module.

### Analogy

A module is a reusable engineering component.

Build it once, parameterize it and reuse it.

---

## 18. Environments

A common structure is:

~~~text
terraform/
├── modules/
├── environments/
│   ├── dev/
│   ├── staging/
│   └── production/
~~~

One module can serve multiple environments with different inputs.

---

## 19. Secrets

Never commit:

- cloud access keys;
- database passwords;
- private keys;
- API tokens.

Prefer:

- CI secret stores;
- environment variables;
- cloud identity mechanisms;
- secret managers.

Mark sensitive outputs when appropriate:

~~~hcl
output "db_password" {
  value     = var.db_password
  sensitive = true
}
~~~

Important:

> Sensitive output settings do not make an insecure state backend safe.

---

## 20. Terraform in CI/CD

A production-oriented flow:

~~~text
Pull Request
   |
   +-- fmt
   +-- validate
   +-- security scan
   +-- plan
   |
   v
Review
   |
   v
Approval
   |
   v
Apply
   |
   v
Verify
~~~

Infrastructure changes deserve code review.

---

## 21. Hands-on lab

Start safely:

~~~bash
mkdir foma-terraform-lab
cd foma-terraform-lab
terraform init
~~~

Create:

~~~text
main.tf
variables.tf
outputs.tf
~~~

Then:

~~~bash
terraform fmt
terraform validate
terraform plan
terraform apply
~~~

Inspect the result.

Clean up when finished:

~~~bash
terraform destroy
~~~

For AWS exercises, understand cost and cleanup before creating paid resources.

---

## 22. Troubleshooting

### Provider error

~~~bash
terraform init
terraform providers
~~~

### Validation error

~~~bash
terraform validate
~~~

Read the exact resource and line reported.

### Unexpected plan

~~~bash
terraform plan
~~~

Ask:

- Did code change?
- Did state change?
- Did someone modify the resource manually?
- Did a provider behavior change?

### State problem

Do not delete state blindly.

Investigate the backend, state lock and resource relationships first.

---

## 23. Production best practices

- Store Terraform in Git.
- Review plans before production apply.
- Use protected remote state.
- Restrict state access.
- Separate environments.
- Reuse modules carefully.
- Control provider versions.
- Scan IaC.
- Avoid hard-coded credentials.
- Minimize manual console changes.
- Protect production applies.
- Test destructive operations outside production.

---

## 24. Knowledge check

1. What is IaC?
2. What is Terraform?
3. What is a provider?
4. What is a resource?
5. What is a variable?
6. What is an output?
7. Why does Terraform need state?
8. What does init do?
9. What does plan do?
10. What does apply do?
11. What is drift?
12. Why protect state?
13. What is a module?
14. Why control production apply?

### Answers

1. Managing infrastructure through code.
2. A declarative IaC tool.
3. A connector to a platform/service.
4. A managed infrastructure object.
5. Reusable input.
6. Useful exposed result.
7. To track managed infrastructure.
8. Initializes providers/modules.
9. Previews changes.
10. Executes changes.
11. Difference between expected and actual infrastructure.
12. State may contain sensitive information.
13. Reusable Terraform configuration.
14. Infrastructure changes can be destructive.

---

## 25. Day 20 challenge

Create reusable Terraform configuration for:

~~~text
dev
staging
production
~~~

Then make CI run:

~~~bash
terraform fmt -check
terraform validate
terraform plan
~~~

Explain how the same infrastructure design can be reused safely.

### FOMA takeaway

> **Terraform turns infrastructure from manual clicks into a reviewable, repeatable engineering system.**

**Learn • Practice • Build • Troubleshoot • Advance**

https://foma.life
