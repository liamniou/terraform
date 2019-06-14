variable "aws_access_key" {
}

variable "aws_secret_key" {
}

variable "aws_region" {
  default = "eu-west-1"
}

variable "rutracker_notifier_bot" {
  description = "Map variable with TG token, DB name, rutracker login and password"
  type        = "map"
}

variable "transmission_management_bot" {
  description = "Map variable with TG token, transmission host, port, user, password and download dir"
  type        = "map"
}

variable "zoya_monitoring_bot" {
  description = "Map variable with TG token, scope, shreadsheet ID, sheet ID"
  type        = "map"
}

variable "shared_budget_bot" {
  description = "Map variable with TG token, TG IDs, scope, shreadsheet ID, sheet ID"
  type        = "map"
}