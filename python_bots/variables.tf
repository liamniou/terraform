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
  default     = {
    "database_name" = "/app/rutracker_notifier.db"
  }
}

variable "transmission_management_bot" {
  description = "Map variable with TG token, transmission host, port, user, password and download dir"
  type        = "map"
  default     = {
    transmission_port = "9091"
    transmission_user = "admin"
    transmission_password = "admin"
  }
}