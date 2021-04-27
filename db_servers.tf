resource "aws_key_pair" "dbserver_pub_key" {
  key_name   = "dbserver_ssh_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDDJ1nwo+yfNWxwo+DTUWLmb4xerGE9qetlD5pa7fFr5dBYVxymaOPdlIs8b+LD4xr2uvvncPfHUVB2vc8hajUrgtVPy/prY/rz+5P8Ugoo0aRyhOezcRW7OVoEcUVA2u4e2I79x0undR6ls/qTfbgUa3QTieMqk12xurK5+yIYT2shFX9xRM2/bjVOF+K4tlEW+tp1qDRVpnl0STwyzTeIVCtj+whPI6atW+H5UaTyRnIQrdhO9PiTwlTqHdIzzwZg/s6ouNlXZtBgyCWdFiXAycNFpyaTt6Gb4xcO3mGLi4h3EJHxlHQKTEirZgnWE1iOn+QKa9yuZTfzAUCw/1nQcSrYWwMUzK72h+tWodfQ19f01pPs6i2TWmXT9OdNkS5uwRs8tauX03h8SIF9vU58NMclSFhXi9r1y62th0krtM3FNCNTChWId3r0LhHcyFWnd62zAElL3a1bkcNLgCT9Y3r0JGiV/Bc2ybq6jDIithu1I80KO0HOu3ySpVxKlJE="

  tags = {
    "Name" = "dbserver_pub_key"
  }
}

resource "aws_instance" "mongodb1" {
  ami                         = "ami-0767046d1677be5a0" # AMI name 'Ubuntu Server 20.04 LTS (HVM), SSD Volume Type'
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.dbserver_pub_key.key_name
  associate_public_ip_address = true
  availability_zone           = "eu-central-1a"
  security_groups             = [aws_security_group.db_server_sg.id]

  root_block_device {
    volume_type = "gp2"
    volume_size = "20"
  }

  # executing with ansible provisioner
  provisioner "local-exec" {
    command = "ansible-playbook -u ubuntu -i ${aws_instance.mongodb1.public_ip}, --private-key ./ssh_keys/dbserver_ssh_key ./ansible/db_server_cfg.yaml"
  }

  tags = {
    "Name" = "mongodb1"
  }
}

resource "aws_instance" "mongodb2" {
  ami                         = "ami-0767046d1677be5a0" # AMI name 'Ubuntu Server 20.04 LTS (HVM), SSD Volume Type'
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.dbserver_pub_key.key_name
  associate_public_ip_address = true
  availability_zone           = "eu-central-1b"
  security_groups             = [aws_security_group.db_server_sg.id]

  root_block_device {
    volume_type = "gp2"
    volume_size = "20"
  }

  # executing with ansible provisioner
  provisioner "local-exec" {
    command = "ansible-playbook -u ubuntu -i ${aws_instance.mongodb2.public_ip}, --private-key ./ssh_keys/dbserver_ssh_key ./ansible/db_server_cfg.yaml"
  }
  
  tags = {
    "Name" = "mongodb2"
  }
}

resource "aws_instance" "mongodb3" {
  ami                         = "ami-0767046d1677be5a0" # AMI name 'Ubuntu Server 20.04 LTS (HVM), SSD Volume Type'
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.dbserver_pub_key.key_name
  associate_public_ip_address = true
  availability_zone           = "eu-central-1c"
  security_groups             = [aws_security_group.db_server_sg.id]

  root_block_device {
    volume_type = "gp2"
    volume_size = "20"
  }

  # executing with ansible provisioner
  provisioner "local-exec" {
    command = "ansible-playbook -u ubuntu -i ${aws_instance.mongodb3.public_ip}, --private-key ./ssh_keys/dbserver_ssh_key ./ansible/db_server_cfg.yaml"
  }
  
  tags = {
    "Name" = "mongodb3"
  }
}
