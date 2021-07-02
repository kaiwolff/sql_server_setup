terraform {
  required_providers {
    aws = {
     source = "hashicorp/aws"
     version = "~>3.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

resource "aws_default_vpc" "Eng88_web_server_vpc_tf" {

}

data "aws_subnet_ids" "Eng88_web_server_subnet_tf"{
  vpc_id = aws_default_vpc.Eng88_web_server_vpc_tf.id
}

resource "aws_security_group" "Eng88_web_server_security_group_tf" {
  name = "Eng88_web_server_security_group"

  vpc_id = aws_default_vpc.Eng88_web_server_vpc_tf.id


  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8099
    to_port = 8099
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol= -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "aws_private_key" {
  default = "/home/kali/.ssh/cyber-jenkins-key.pem"
}
resource "aws_s3_bucket" "Eng88_web_server_db_tf" {
  bucket = "Eng88webserverdb"
  acl = "private"

  tags = {
    Name = "Eng-88 Cyber - Eng88 Web Server Bucket"
    Environment = "Dev"
  }
}

resource "aws_instance" "Eng88_web_server_instance_tf" {
  ami                         = "ami-0f89681a05a3a9de7"
  instance_type               = "t2.micro"
  subnet_id                   = tolist(data.aws_subnet_ids.Eng88_web_server_subnet_tf.ids)[0]
  associate_public_ip_address = true
  key_name                    = "cyber-jenkins-key"
  vpc_security_group_ids      = [aws_security_group.Eng88_web_server_security_group_tf.id]

  connection {
    type = "ssh"
    host = self.public_ip
    user = "ec2-user"
    private_key = file(var.aws_private_key)

  }
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo amazon-linux-extras install docker -y",
      "sudo yum install docker -y",
      "sudo service docker start",
      "sudo usermod -a -G docker ec2-user"
    ]
  }
  provisioner "remote-exec" {
    inline = [
      "docker run -d -p 80:5000 jamesdidit72/account-generation"
    ]
  }
  provisioner "file" {
    source = "./init-scripts"
    destination = "/tmp/init-scripts"
  }
  provisioner "file" {
    source = "./.mysql_password"
    destination = "tmp/.mysql_password"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/init-scripts/docker_install.sh",
      "/tmp/init-scripts/docker_install.sh",
    ]
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/init-scripts/mysql_install.sh",
      "tmp/init-scripts/mysql_install.sh",
    ]
  }
  provisioner "file" {
    source = "./init-sql"
    destination = "/tmp"
  }
  provisioner "remote-exec" {
    when = destroy
    inline = [
      "chmod +x /tmp/init-scripts/stop.sh",
      "/tmp/init-scripts/stop.sh",
    ]
  }
}

resource "aws_volume_attachment" "Eng88_web_server_db_volume_attachment_tf" {
  device_name = "/dev/xvdz"
  volume_id = "vol-0e32e0dd6a7e660f4"
  instance_id = aws_instance.Eng88_web_server_instance_tf.id
  skip_destroy = true

  connection {
    type = "ssh"
    host = aws_instance.Eng88_web_server_instance_tf.public_ip
    user = "ec2-user"
    private_key = file(var.aws_private_key)
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/init-scripts/mount.sh",
      "/tmp/init-scripts/mount.sh",
      "/tmp/init-scripts/mount/sh"
    ]
  }
  provisioner "remote-exec" {
    inline = [
      "cd /tmp/init-scripts/",
      "chmod +x launch.sh",
      "./launch.sh"
    ]
  }
}
