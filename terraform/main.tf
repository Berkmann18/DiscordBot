# resource "digitalocean_app" "discordbot" {
#   spec {
#     name   = var.project
#     region = "fra" #var.region
#     domain {
#       name = "berkmc.xyz"
#     }

#     env {
#       key   = "BOT_TOKEN"
#       value = var.BOT_TOKEN
#       type  = "SECRET"
#     }

#     env {
#       key   = "ROLEID"
#       value = var.ROLEID
#       type  = "SECRET"
#     }

#     env {
#       key   = "CHANNELID"
#       value = var.CHANNELID
#       type  = "SECRET"
#     }

#     env {
#       key   = "ACCESSKEY"
#       value = var.ACCESSKEY
#       type  = "SECRET"
#     }

#     env {
#       key   = "SECRETKEY"
#       value = var.SECRETKEY
#       type  = "SECRET"
#     }

#     env {
#       key   = "INSTANCE"
#       value = var.INSTANCE
#       type  = "SECRET"
#     }

#     env {
#       key   = "MESSAGELOGGING"
#       value = var.MESSAGELOGGING
#       type  = "SECRET"
#     }

#     service {
#       name               = "bot-service" #?
#       # environment_slug   = "nodejs"      #?
#       instance_count     = 1
#       instance_size_slug = "basic-xs" #?

#       git {
#         repo_clone_url = "https://github.com/Berkmann18/DiscordBot.git"
#         branch         = "master"
#       }
#     }
#   }
# }
resource "digitalocean_droplet" "discordbot" {
  image = "ubuntu-20-04-x64"
  name = var.project
  region = var.region
  size = "s-1vcpu-1gb"
  private_networking = true
  # backups = true
  monitoring = true
  ssh_keys = [
    data.digitalocean_ssh_key.terraform.id
  ]

  connection {
    host = self.ipv4_address
    user = "root"
    type = "ssh"
    private_key = file(var.pvt_key)
    timeout = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      "sudo apt-get update",
      "sudo apt-get -y install git npm",
      "npm i -g pm2",
      "git clone https://github.com/Berkmann18/DiscordBot.git",
      "cd DiscordBot && npm i",
      "pm2 start src/bot.js" # "npm start"
    ]
  }

  tags = [ "DiscordBot", "MineServ" ]
}

resource "digitalocean_floating_ip" "fip" {
  droplet_id = digitalocean_droplet.discordbot.id
  region = digitalocean_droplet.discordbot.region
  # droplet_id = digitalocean_app.discordbot.id
  # region     = var.region
}

resource "digitalocean_firewall" "gate" {
  name        = "only-ssh-http"
  droplet_ids = [digitalocean_droplet.discordbot.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = var.allowed_cidrs
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "icmp"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

# Maybe consider using digitalocean_app instead? https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/app
