resource "yandex_compute_instance" "test" {
  name     = "test"
  hostname = "test"
  

  resources {
    cores = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id    = "${var.instances_img}"
      name        = "root-test"
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
