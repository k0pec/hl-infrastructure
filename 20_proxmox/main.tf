terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = ">=1.0.0"
    }
  }
  required_version = ">= 0.14"
}

provider "proxmox" {
        pm_api_url      = "https://192.168.56.101:8006/api2/json"
        pm_api_token_id = "root@pam!root_api_token"
        pm_api_token_secret = "88dc60c1-bab3-44b5-ae02-83bf42eda177"
        pm_tls_insecure = true
        
        pm_log_enable   = true
        pm_log_file     = "tf-plugin-proxmox.log"
        pm_debug        = true
        pm_log_levels   = {
                _default        = "debug"
                _capturelog     = ""
        }
}
