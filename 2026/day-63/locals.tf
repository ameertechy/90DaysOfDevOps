locals {
  name_prefix = "${var.project_name}-${var.environment}"

  monitoring_enabled = var.environment == "prod" ? true : var.enable_detailed_monitoring

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.extra_tags
  )
}