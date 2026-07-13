variable "region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "Project name used in resource names and tags"
  type        = string
  # no default -- Terraform will REFUSE to run without a value
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "instance_count" {
  description = "How many instances (number type demo)"
  type        = number
  default     = 1
}

variable "enable_detailed_monitoring" {
  description = "Enable EC2 detailed monitoring (bool type demo)"
  type        = bool
  default     = false
}

variable "allowed_ports" {
  description = "Ingress ports for the security group"
  type        = list(number)
  default     = [22, 80, 443]
}

variable "extra_tags" {
  description = "Additional tags merged onto every resource"
  type        = map(string)
  default     = {}
}