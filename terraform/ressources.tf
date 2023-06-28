// fetch the latest debian release image from their mirrors
resource "libvirt_volume" "base" {
  name   = "debian-base"
  source = var.debian_iso_url
  pool   = var.libvirt_pool
  format = "qcow2"
}

resource "libvirt_volume" "debian-os_image" {
  name            = "debian-os_image"
  base_volume_id  = libvirt_volume.base.id
  pool            = var.libvirt_pool
  size            = 10737418240
}

// Use CloudInit ISO to add ssh-key to the instance
resource "libvirt_cloudinit_disk" "commoninit" {
  name           = "${var.hostname}-commoninit.iso"
  pool           = var.libvirt_pool
  user_data      = data.template_cloudinit_config.config.rendered
  network_config = data.template_file.network_config.rendered
}

// Create the machine
resource "libvirt_domain" "domain-debian" {
  # domain name in libvirt, not hostname
  name       = var.hostname
  memory     = var.memoryMB
  vcpu       = var.cpu
  autostart  = true
  qemu_agent = true
  timeouts {
    create = "20m"
  }


  disk {
    volume_id = libvirt_volume.debian-os_image.id
  }
  network_interface {
    network_name = var.libvirt_net
    mac          = var.mac_addr
    wait_for_lease = true
  }

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = "true"
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait",
    ]

    connection {
      host     = "${self.network_interface.0.addresses.0}"
      type     = "ssh"
      user     = "admuser"
      private_key = "${file("~/.ssh/id_rsa")}"
    }
  }

  provisioner "local-exec" {
    #command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u admuser -i ${self.network_interface.0.addresses.0}, --ask-vault-pass --extra-vars '@passwd.yml' --private-key ${var.private_key_path} ansible/provision.yml"
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u admuser -i ${self.network_interface.0.addresses.0}, --extra-vars 'ansible_become_pass=${var.password_usradm}' --private-key ${var.private_key_path} ansible/provision.yml"
  }
}
