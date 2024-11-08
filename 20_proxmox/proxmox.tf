resource "proxmox_vm_qemu" "kali_from_template" {
        name = "TERRAFORM-TEST"
        clone = "kali"
        target_node     = "pve1"
        agent = 1
        cpu = "host"
        cores = 1
        sockets = 1
        memory = 512
        scsihw = "virtio-scsi-pci"
        bootdisk = "scsi0"
        disk {
            slot = 0
            size = "100G"
            type = "scsi"
            storage = "local"
            iothread = 1
        }
        network {
            model = "virtio"
            bridge = "vmbr0"
        }
}