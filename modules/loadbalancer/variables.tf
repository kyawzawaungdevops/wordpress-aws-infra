variable "prefix" {
  type        = string
  description = "Prefix for resources"
}
variable "azs" {
  type        = list(string)
  description = "Availability Zones"
}
variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for EC2 instances"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for security group"
}

variable "instance_ids" {
  type = list(string)
}

variable "target_port" {
  type    = number
  default = 80
}

variable "health_check_path" {
  type    = string
  default = "/"
}