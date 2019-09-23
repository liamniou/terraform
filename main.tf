provider "digitalocean" {
  token = "${var.do_token}"
}

data "digitalocean_image" "debian_base" {
  name = "debian_base"
}

resource "digitalocean_droplet" "example" {
  name   = "example"
  region = "ams3"
  size   = "s-1vcpu-1gb"
  image  = "${data.digitalocean_image.debian_base.image}"
}
