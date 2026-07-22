resource "tls_private_key" "deploy_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "deploy_key" {
  key_name   = "devops-academico-key"
  public_key = tls_private_key.deploy_key.public_key_openssh
}

resource "aws_instance" "app" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.deploy_key.key_name
  vpc_security_group_ids      = [var.security_group_id]
  associate_public_ip_address = true
  user_data_replace_on_change = true

  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    db_endpoint = var.db_endpoint
    db_port     = var.db_port
    db_name     = var.db_name
    db_username = var.db_username
    db_password = var.db_password
    api_port    = var.api_port
    repo_url    = var.repo_url
  })

  tags = {
    Name = "devops-academico-api"
  }
}

resource "aws_eip" "app_ip" {
  instance = aws_instance.app.id
}
