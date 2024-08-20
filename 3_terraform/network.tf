# Network
resource "yandex_vpc_network" "my_net" {
  name = "net"
}

resource "yandex_vpc_subnet" "my_subnet" {
  name = "subnet_b"
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.my_net.id}"
  v4_cidr_blocks = ["192.168.101.0/24"]
}