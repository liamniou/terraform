variable "do_token" {
  description = "DigitalOcean API access token"
}

# Shared Budget Bot

variable "shared_budget_bot_pickle_gdrive_id" {
  description = "Google Sheets pickle ID"
}

variable "shared_budget_bot_token" {
  description = "Telegram bot token for Shared Budget bot"
}

variable "person_1_tg_id" {
  description = "Shared Budget bot person_1 Telegram ID"
}

variable "person_2_tg_id" {
  description = "Shared Budget bot person_2 Telegram ID"
}

variable "scope" {
  description = "Shared Budget bot Google Sheets Scope URL"
}

variable "spreadsheet_id" {
  description = "Shared Budget bot Google Sheets Spreadsheet ID"
}

variable "sheet_id" {
  description = "Shared Budget bot Google Sheets Sheet ID"
}

variable "transmission_management_bot_token" {
  description = "Telegram bot token for Transmission management bot"
}

variable "transmission_host" {
  default     = "localhost" 
  description = "Transmission host"
}

variable "transmission_port" {
  default = "9091"
  description = "Transmission port"
}

variable "transmission_user" {
  default     = "transmission"
  description = "Transmission user"
}

variable "transmission_password" {
  default     = "transmission"
  description = "Transmission password"
}

variable "transmission_download_dir" {
  default     = "/tmp/downloads"
  description = "Transmission download dir"
}

variable "id_rsa" {
  description = "Private RSA key"
}

variable "storage_host" {
  description = "Remote storage hostname for SSH"
}

variable "storage_port" {
  description = "Remote storage port for SSH"
}

// variable "rutracker_notifier_bot_token" {
//   description = "Telegram bot token for rutracker_notifier_bot"
// }

// variable "mongo_connection_string" {
// }
