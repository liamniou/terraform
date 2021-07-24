resource "digitalocean_droplet" "bots" {
  image    = "docker-20-04"
  name     = "bots"
  region   = "ams3"
  size     = "s-1vcpu-1gb"
  ssh_keys = ["29239323"]

  user_data = templatefile(
    "templates/user_data.tpl", {
      shared_budget_bot_token           = var.shared_budget_bot_token,
      pickle_gdrive_id                  = var.shared_budget_bot_pickle_gdrive_id, 
      person_1_tg_id                    = var.person_1_tg_id,
      person_2_tg_id                    = var.person_2_tg_id,
      scope                             = var.scope,
      spreadsheet_id                    = var.spreadsheet_id,
      sheet_id                          = var.sheet_id,
      transmission_settings             = templatefile("templates/transmission_settings.tpl", {}),
      transmission_management_bot_token = var.transmission_management_bot_token,
      transmission_host                 = var.transmission_host,
      transmission_port                 = var.transmission_port,
      transmission_user                 = var.transmission_user
      transmission_password             = var.transmission_password,
      transmission_download_dir         = var.transmission_download_dir,
      storage_port                      = var.storage_port,
      storage_host                      = var.storage_host,
      id_rsa                            = var.id_rsa,
      script_torrent_done               = templatefile("templates/script_torrent_done.tpl", {
        storage_port = var.storage_port,
        storage_host = var.storage_host,
        bot_token = var.transmission_management_bot_token,
        tg_id = var.person_1_tg_id
      }),
      NOTIFICATION_URL = var.NOTIFICATION_URL,
    }
  )
}

// data "template_file" "rutracker_notifier_bot_setup_script" {
//   template = file("templates/setup_rutracker_notifier_bot.tpl")
//   vars = {
//     token                   = var.rutracker_notifier_bot_token
//     mongo_connection_string = var.mongo_connection_string
//   }
// }
// }
