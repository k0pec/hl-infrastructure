resource "yandex_compute_instance" "host2" {
  name = "host2"
  

  resources {
    cores = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id    = "${var.instances_img}"
      name        = "root-host2"
      type        = "network-nvme"
      size        = "10"
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.my_subnet.id}"
    nat       = true
  }

  metadata = {
    user-data = "${file("meta.txt")}"
  }
}
