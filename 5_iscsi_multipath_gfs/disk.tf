resource "yandex_compute_disk" "empty-disk" {
  name       = "empty-disk"
  type       = "network-hdd"
  zone       = "ru-central1-a"
  size       = "10"
  block_size = "4096"
}