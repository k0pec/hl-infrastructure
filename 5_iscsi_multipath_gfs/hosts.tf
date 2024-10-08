resource "local_file" "hosts" {
  content = <<-DOC
    # Ansible inventory containing variable values from Terraform.
    # Generated by Terraform.

    [target]
    target ansible_host=${yandex_compute_instance.target.network_interface.0.nat_ip_address}

    [client]
    host1 ansible_host=${yandex_compute_instance.host1.network_interface.0.nat_ip_address}
    host2 ansible_host=${yandex_compute_instance.host2.network_interface.0.nat_ip_address}

    [iscsi_group]
    target
    host1
    host2

    [iscsi_group:vars]
    target_ip=${yandex_compute_instance.target.network_interface.0.ip_address}
    host1_ip=${yandex_compute_instance.host1.network_interface.0.ip_address}
    host2_ip=${yandex_compute_instance.host2.network_interface.0.ip_address}

    DOC
  filename = "hosts"

  depends_on = [
    yandex_compute_instance.target,
    yandex_compute_instance.host1,
    yandex_compute_instance.host2
  ]
}
