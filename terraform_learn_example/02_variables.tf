variable "region" {
  default = "us-east-1"
}


variable "profile" {
  default = "dev-mfa"
}


variable "sshpubkey_path" {
  type = "string"
  default = "~/.ssh/id_rsa.pub"
}

variable "amis" {
  type = "map"
  default = {
    "us-east-1" = "ami-0b69ea66ff7391e80"
    "us-east-2" = "ami-00c03f7f7f2ec15c3"
    "us-west-1" = "ami-0245d318c6788de52"
    "us-west-2" = "ami-04b762b4289fba92b"
  }
}
