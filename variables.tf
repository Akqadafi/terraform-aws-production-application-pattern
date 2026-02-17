########################################
# ROOT VARIABLES (lab1c/variables.tf)
########################################

variable "project_name" {
  description = "Name prefix used for tagging and resource naming (e.g., arcanum, shibuya)."
  type        = string
  default     = "arcanum"
}

variable "env" {
  description = "Environment name (e.g., dev, lab, prod). Used in tags if you want it."
  type        = string
  default     = "lab"
}

variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "ap-northeast-1"
}

########################################
# NETWORK
########################################

variable "vpc_cidr" {
  description = "VPC CIDR block."
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability zones to use. Must align with subnet CIDR counts."
  type        = list(string)
  default     = ["ap-northeast-1a", "ap-northeast-1c"]
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs, one per AZ."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs, one per AZ."
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

########################################
# SECURITY
########################################

variable "my_ip_cidr" {
  description = "Your public IP in CIDR form for SSH access (e.g., 203.0.113.10/32)."
  type        = string
  # No default on purpose: forces you to set it safely
}

########################################
# DATABASE (RDS + Secret)
########################################

variable "db_engine" {
  description = "RDS engine."
  type        = string
  default     = "mysql"
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "storage_type" {
  description = "RDS storage type."
  type        = string
  default     = "gp2"
}

variable "db_name" {
  description = "Initial database name."
  type        = string
  default     = "arcdb"
}

variable "db_username" {
  description = "Database master username."
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Database master password."
  type        = string
  sensitive   = true
  # No default on purpose
}

########################################
# EC2 APP
########################################

variable "ec2_instance_type" {
  description = "EC2 instance type for app host."
  type        = string
  default     = "t3.micro"
}

########################################
# MONITORING (SNS)
########################################

variable "sns_email_endpoint" {
  description = "Email address to receive SNS alarm notifications."
  type        = string
  # No default on purpose
}