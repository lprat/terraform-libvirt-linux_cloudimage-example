
// variables that can be overriden
# Host name
variable "hostname" { default = "lionel" }
# Domaine name
variable "domain" { default = "csirt.local" }
# IP address obtain
variable "ip_type" { default = "dhcp" } # dhcp is other valid type
# VM memory
variable "memoryMB" { default = 1024 * 2 }
# VM CPU
variable "cpu" { default = 2 }
# KVM pool to use -- virsh pool-list --all
variable "libvirt_pool" { default = "pool" }
# KVM net to use -- virsh net-list --all
variable "libvirt_net" { default = "default" }
# URL ISO DEBIAN to use
variable "debian_iso_url" { default = "https://cloud.debian.org/images/cloud/bookworm/daily/latest/debian-12-genericcloud-amd64-daily.qcow2" }
# ADDRESS IP
variable "ip_addr" { default = "192.168.1.1" }
# VM MAC ADDRESS
variable "mac_addr" { default = "52:54:00:36:14:e5" }
# Level Hardening - https://github.com/hardenedlinux/harbian-audit/blob/master/bin/hardening.sh#L69-L78
variable "hardening_level" { default = "5" }
# SSH access autorize IP address (192.168.0.1,192.168.10.1)or network (192.168.0.0/24) - if you have bastion use this address
variable "ssh_ip_access" { default = "192.168.122.0/24" }
# SSH private key used by terraform & ansible to connect at VM
variable "private_key_path" {
  description = "Path to the private SSH key, used to access the instance."
  default     = "~/.ssh/id_rsa"
}
# Root password
variable "password_root" {
  type        = string
  sensitive   = true
}
# User "admuser" password
variable "password_usradm" {
  type        = string
  sensitive   = true
}

# Data used by config cloud-init
data "template_file" "user_data" {
  template = file("${path.module}/cloud-init/cloud-init.cfg")
  vars = {
    hostname        = var.hostname
    fqdn            = "${var.hostname}.${var.domain}"
    domain          = var.domain
    public_key      = file("~/.ssh/id_rsa.pub")
    root_pass       = var.password_root 
    admuser_pass    = var.password_usradm
    hardening_level = var.hardening_level
    ssh_ip_access   = var.ssh_ip_access    
  }
}

data "template_cloudinit_config" "config" {
  gzip          = false
  base64_encode = false
  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = data.template_file.user_data.rendered
  }
}

data "template_file" "network_config" {
  template = file("${path.module}/cloud-init/network_config_${var.ip_type}.cfg")
  vars = {
    domain  = var.domain
    ip_addr = var.ip_addr
  }
}
