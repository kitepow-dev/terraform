provider "proxmox" {
  pm_api_url = "https://***.***.***.***:8006/"
  pm_username = "***@pve"
  pm_password = "***"
  insecure = true

  ssh {
    agent = true
    # Uncomment below for using api_token
    # username = "root"
  }
}

resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "pve"

  url = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
}


resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
  name      = "ubuntu-vm"
  node_name = "pve"

  initialization {
    ip_config {
      ipv4 {
        address = "***.***.***.***/24"
        gateway = "***.***.***.1"
      }
    }

    user_account {
      username = "ubuntu"
      keys     = [var.ssh_key]
    }
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 20
  }

  network_device {
    bridge = "vmbr0"
  }
}

