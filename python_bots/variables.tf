variable "do_token" {
  description = "DigitalOcean API access token"
}

variable "workspace_id" {
  description = "ID of Terraform cloud workspace"
}

variable "tf_cloud_token" {
  description = "Token to access Terraform cloud account"
}

variable "best_wines_tg_token" {
  description = "Telegram bot token of best_wines_sweden_bot"
}

variable "best_wines_chat_id" {
  description = "ID of the chat that bot will send messages to"
}

variable "telegraph_token" {
  description = "Telegraph token of best_wines_sweden_bot"
}

variable "chrome_timeout" {
  description = "Timeout in ms that Chrome wait for a page to load"
  default     = 10000
}

variable "personal_tg_id" {
  description = "Telegram ID of a user to send notification messages to"
}