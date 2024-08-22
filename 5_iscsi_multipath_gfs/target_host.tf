resource "yandex_compute_instance" "target" {
  name = "target"
  

  resources {
    cores = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id    = "${var.instances_img}"
      name        = "root-target"
      type        = "network-nvme"
      size        = "10"
    }
  }

  secondary_disk {
    disk_id = "${yandex_compute_disk.empty-disk.id}"
    }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.my_subnet.id}"
    nat       = true
  }

  metadata = {
    user-data = "${file("meta.txt")}"
  }
}
