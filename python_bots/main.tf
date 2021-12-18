resource "digitalocean_droplet" "best_wines_bot" {
  image    = "docker-20-04"
  name     = "bots"
  region   = "ams3"
  size     = "s-2vcpu-4gb"
  ssh_keys = ["29239323"]

  user_data = templatefile(
    "templates/user_data.tpl", {
      best_wines_tg_token = var.best_wines_tg_token
      best_wines_chat_id  = var.best_wines_chat_id
      chrome_timeout      = var.chrome_timeout
      personal_tg_id      = var.personal_tg_id
      tf_cloud_token      = var.tf_cloud_token
      workspace_id        = var.workspace_id
    }
  )
}
