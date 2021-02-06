output "FIP" {
  description = "Floating IP of the instance"
  value       = digitalocean_floating_ip.fip.ip_address
  sensitive = true # var.redact_info
}

output "Status" {
  value = digitalocean_droplet.discordbot.status
}

output "Tags" {
  value = digitalocean_droplet.discordbot.tags
}

output "IPv4" {
  value = digitalocean_droplet.discordbot.ipv4_address
  sensitive = true # var.redact_info
}

# output "URL" {
#   value = digitalocean_app.discordbot.live_url
# }