resource "digitalocean_droplet" "discordbot" {
  image              = "ubuntu-20-04-x64"
  name               = var.project
  region             = var.region
  size               = "s-1vcpu-1gb"
  private_networking = true
  # backups = true
  monitoring = true
  ssh_keys = [
    data.digitalocean_ssh_key.terraform.id
  ]

  connection {
    host        = self.ipv4_address
    user        = "root"
    type        = "ssh"
    private_key = file(var.pvt_key)
    timeout     = "2m"
  }

  user_data = "#cloud-config\npackage_update: true\npackage_upgrade: true"

  provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      "sudo apt-get update",
      "sudo apt-get -y install git nodejs npm awscli",
      "npm i -g pm2",
      "git clone https://github.com/Berkmann18/DiscordBot.git",
      "cd DiscordBot && npm i",
      "aws --profile default configure set aws_access_key_id '${var.ACCESSKEY}'",
      "aws --profile default configure set aws_secret_access_key '${var.SECRETKEY}'",
      "aws --profile default configure set region ${var.aws_region}",
      "aws --profile default configure set output json",
      "echo 'BOT_TOKEN=${var.BOT_TOKEN}\nROLEID=${var.ROLEID}\nCHANNELID=${var.CHANNELID}\nACCESSKEY=${var.ACCESSKEY}\nSECRETKEY=${var.SECRETKEY}\nINSTANCE=${var.INSTANCE}\nMESSAGELOGGING=${var.MESSAGELOGGING}' > .env",
      "pm2 start src/bot.js", # "npm start"
      "pm2 startup systemd"
    ]
  }

  tags = ["DiscordBot", "MineServ"]
}

resource "digitalocean_floating_ip" "fip" {
  droplet_id = digitalocean_droplet.discordbot.id
  region     = digitalocean_droplet.discordbot.region
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