
// variables that can be overriden
variable "hostname" { default = "test" }
variable "domain" { default = "csirt.local" }
variable "ip_type" { default = "dhcp" } # dhcp is other valid type
variable "memoryMB" { default = 1024 * 1 }
variable "cpu" { default = 1 }
variable "libvirt_pool" { default = "pool" } #virsh pool-list --all
variable "libvirt_net" { default = "default" } #virsh net-list --all
variable "ubuntu_ver" { default = "jammy" }
variable "ubuntu_iso" { default = "22.04" }
variable "ip_addr" { default = "192.168.1.1" }
variable "mac_addr" { default = "52:54:00:36:14:e5" }
variable "private_key_path" {
  description = "Path to the private SSH key, used to access the instance."
  default     = "~/.ssh/id_rsa"
}
variable "password_root" {
  type        = string
  sensitive   = true
}
variable "password_usradm" {
  type        = string
  sensitive   = true
}

//datas
data "template_file" "user_data" {
  template = file("${path.module}/cloud-init/cloud-init.cfg")
  vars = {
    hostname     = var.hostname
    fqdn         = "${var.hostname}.${var.domain}"
    domain       = var.domain
    public_key   = file("~/.ssh/id_rsa.pub")
    root_pass    = var.password_root 
    admuser_pass = var.password_usradm
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
