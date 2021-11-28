data "template_file" "cloud-init" {
  template = file("${path.module}/templates/cloud-init.yaml")

  vars = {
    ssh_public_key = var.ssh-public-key
    region         = var.region
    public_ip      = aws_eip.static.public_ip
    ssh_port       = var.ssh-port
    domain         = var.domain
  }
}

data "template_cloudinit_config" "astronautcount" {
  gzip          = false
  base64_encode = true

  # Main conf
  part {
    filename     = data.template_file.cloud-init.filename
    content_type = "text/cloud-config"
    content      = data.template_file.cloud-init.rendered
  }
}
