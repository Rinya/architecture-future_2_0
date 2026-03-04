output "vpc_network_id" {
  value = yandex_vpc_network.main.id
}

output "subnet_ids" {
  value = { for k, v in yandex_vpc_subnet.subnets : k => v.id }
}

output "vm_instances_ips" {
  value = { for k, v in yandex_compute_instance.vms : k => v.network_interface[0].nat_ip_address }
}

output "generated_ssh_private_key" {
  description = "Generated SSH private key for VM access"
  value       = tls_private_key.vm_ssh_key.private_key_openssh
  sensitive   = true
}
