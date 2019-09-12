provider "aws" {
  profile    = var.profile
  region     = var.region
}


data "http" "myip" {
    url = "http://ipv4.icanhazip.com"
}

resource "aws_instance" "example" {
  ami           = var.amis[var.region]
  instance_type = "t2.micro"
  root_block_device {
      volume_size = 10
  }
  tags = {
      builder = "terraform"
  }
  key_name = "${aws_key_pair.test_key.id}"
  user_data_base64 = "IyEvYmluL2Jhc2gKeXVtIC15IGluc3RhbGwgaHR0cGQKc2VydmljZSBodHRwZCBzdGFydAo="
  vpc_security_group_ids = [ "${aws_security_group.allow_http_self_ssh.id}"
  ]
  depends_on = ["aws_security_group.allow_http_self_ssh", "aws_key_pair.test_key"]
  provisioner "local-exec" {
    command = "echo ${aws_instance.example.public_ip} > ip_address.txt"
  }
}

data "template_file" "my_public_key" {
  template = "${file("${var.sshpubkey_path}")}"
}

resource "aws_key_pair" "test_key" {
    key_name = "terraform_key"
    public_key = "${data.template_file.my_public_key.rendered}"
    }

resource "aws_security_group" "allow_http_self_ssh" {
    name = "allow_http_self_ssh"
    description = "Allow HTTP inbound"
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    revoke_rules_on_delete = true
    tags = {
        builder = "terraform"
    }
}

resource "aws_eip" "ip" {
    vpc = true
    instance = aws_instance.example.id
    tags = {
        builder = "terraform"
    }
}


output "instance_ip_addr" {
  value = aws_eip.ip.public_ip
}

output "sshkey" {
  value = aws_key_pair.test_key.public_key
}
