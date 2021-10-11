data "template_file" "ssh" {
  template = file("${path.module}/templates/ssh.yaml")

  vars = {
    ssh_public_key = var.ssh-public-key
    region         = var.region
    public_ip      = aws_eip.static.public_ip
  }
}

data "template_cloudinit_config" "astronautcount" {
  gzip          = false
  base64_encode = true

  # Main conf
  part {
    filename     = data.template_file.ssh.filename
    content_type = "text/cloud-config"
    content      = data.template_file.ssh.rendered
  }
}
