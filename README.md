# WordPress on AWS — Infrastructure Overview

This project provisions a WordPress application on AWS using Terraform, structured into four reusable modules.

## Architecture

```
Internet → ALB (public) → EC2 instances (private) → RDS MySQL (private)
```

## Modules

| Module | Description |
|--------|-------------|
| `vpc` | VPC, public/private subnets across 2 AZs |
| `compute` | EC2 instances running Nginx + PHP 8.3 + WordPress |
| `loadbalancer` | Public-facing Application Load Balancer |
| `rds` | Managed MySQL database |

## Key Design Decisions

- EC2 instances have **no public IP** — all traffic goes through the ALB
- RDS is **only accessible from EC2**, not the internet
- Infrastructure is spread across **2 Availability Zones**
- WordPress configuration (DB host, name, credentials) is injected into EC2 at boot via Terraform `templatefile`
- EC2 key pair is auto-generated and saved locally for SSH access

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Outputs

| Output | Description |
|--------|-------------|
| `alb_dns_name` | WordPress site URL |
| `rds_host` | RDS endpoint (hostname only) |