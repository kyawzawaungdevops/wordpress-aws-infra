variable "prefix" {
 type        = string
 description = "Prefix for resources"
}

variable "public_subnet_cidrs" {
 type        = list(string)
 description = "Public Subnet CIDR values"
}

variable "private_subnet_cidrs" {
 type        = list(string)
 description = "Private Subnet CIDR values"
}

variable "database_subnet_cidrs" {
 type        = list(string)
 description = "Database Subnet CIDR values"
}

variable "azs" {
 type        = list(string)
 description = "Availability Zones"
}