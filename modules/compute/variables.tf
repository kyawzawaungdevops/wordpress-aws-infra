variable "prefix" {
  type        = string
  description = "Prefix for resources"
}
variable "azs" {
 type        = list(string)
 description = "Availability Zones"
}
variable "subnet_ids" {
  type = list(string)
  description = "List of subnet IDs for EC2 instances"
}

variable "vpc_id" {
  type = string
  description = "VPC ID for security group"
}

variable "db_name" {
  type        = string
  description = "Database name"
}

variable "db_username" {
  type        = string
  description = "Database username"
}

variable "db_password" {
  type        = string
  description = "Database password"
}

variable "db_host" {
  type        = string
  description = "Database host"
}