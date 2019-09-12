All files are .tf

~~~
provider "aws" {
  profile    = "dev-mfa"
  region     = "us-east-1"
}

resource "aws_instance" "example" {
  ami           = "ami-0b69ea66ff7391e80"
  instance_type = "t2.micro"
  root_block
}
~~~

This will begin your set up and download any necessary modules.

`terraform init`


Gonna create some user data to install apache

~~~ 
#!/bin/bash
yum -y install httpd
service httpd start
~~~

added more bits.



Referencing an SSH key from file:

in vars.tf:
~~~

variable "sshpubkey_path" {
  type = "string"
  default = "~/.ssh/id_rsa.pub"
}
~~~

to make that get configured, your build.tf

~~~

data "template_file" "my_public_key" {
  template = "${file("${var.sshpubkey_path}")}"
}

resource "aws_key_pair" "test_key" {
    key_name = "terraform_key"
    public_key = "${data.template_file.my_public_key.rendered}"
    }
~~~


Create Ingress rule to allow SSH from personal IP

~~~


data "http" "myip" {
    url = "http://ipv4.icanhazip.com"
}

...

resource "aws_security_group" "allow_http_self_ssh" {
    name = "allow_http_self_ssh"
...
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
    }
...
}
~~~