output "internal_ip_address_target_yandex_cloud" {
  value = "${yandex_compute_instance.target.network_interface.0.ip_address}"
}

output "external_ip_address_target_yandex_cloud" {
  value = "${yandex_compute_instance.target.network_interface.0.nat_ip_address}"
}

output "internal_ip_address_host1_yandex_cloud" {
  value = "${yandex_compute_instance.host1.network_interface.0.ip_address}"
}

output "external_ip_address_host1_yandex_cloud" {
  value = "${yandex_compute_instance.host1.network_interface.0.nat_ip_address}"
}

output "internal_ip_address_host2_yandex_cloud" {
  value = "${yandex_compute_instance.host2.network_interface.0.ip_address}"
}

output "external_ip_address_host2_yandex_cloud" {
  value = "${yandex_compute_instance.host2.network_interface.0.nat_ip_address}"
}