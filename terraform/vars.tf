variable "do_token" {
  description = "DigitalOcean API token"
}

variable "pvt_key" {}
# variable "pub_key" {}

variable "region" {
  description = "DO region"
  default     = "lon1"
}

variable "allowed_cidrs" {
  description = "CIDR allowlist"
}

# variable "mc_only_cidrs" {
#   description = "Minecraft-specific CIDR allowlist"
# }

variable "project" {
  default = "aws-discordbot"
}

variable "BOT_TOKEN" {}
variable "ROLEID" {}
variable "CHANNELID" {}
variable "ACCESSKEY" {}
variable "SECRETKEY" {}
variable "INSTANCE" {}
variable "MESSAGELOGGING" {}

variable "redact_info" {
  default = true
}