resource "null_resource" "wait" {
  provisioner "local-exec" {
    command = "sleep 100"
  }

  depends_on = [
    local_file.hosts
  ]
}

resource "null_resource" "cluster" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i hosts -u test --private-key=/root/.ssh/id_rsa playbook.yml"
  }

  depends_on = [
    null_resource.wait
  ]
}