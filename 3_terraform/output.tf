#output "internal_ip_address_test_yandex_cloud" {
#  value = "${yandex_compute_instance.test.network_interface.0.ip_address}"
#}

output "external_ip_address_test_yandex_cloud" {
  value = "${yandex_compute_instance.test.network_interface.0.nat_ip_address}"
}