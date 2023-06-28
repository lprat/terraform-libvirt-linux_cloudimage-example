output "ips" {
  #value = libvirt_domain.domain-alma
  #value = libvirt_domain.domain-alma.*.network_interface
  # show IP, run 'terraform refresh' if not populated
  value = libvirt_domain.domain-debian.network_interface.0.addresses.0
}
