resource "proxmox_vm_qemu" "ubuntu2204" {
    name = "Ununtu2204"
    desc = "Ubuntu2204"

    target_node = "px01"
    iso = "ubuntu2204-template"

    agent = 1

    os_type = "cloud-init"
    cores = 2
    sockets = 2
    vcpus = 0
    cpu = "host"
    memory = 2048
    scsihw = "virtio-scsi-single"
    disks {
        ide {
            ide3 {
                cloudinit {
                    storage = var.storage_name
                }
            }
        }
        virtio {
            virtio0 {
                disk {
                    size            = "2252M"
                    storage         = var.storage_name
                    replicate       = true
                }
            }
        }
    }

    network {
        model = "virtio"
        bridge = "vmbr0"
    }

    boot = "order=virtio0"
    ipconfig0 = "ip=dhcp"
    nameserver = "8.8.8.8"
    ciuser = "test"
}