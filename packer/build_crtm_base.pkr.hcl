packer {
  required_version = ">= 1.9.0"

  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.2.0"
    }
  }
}

locals {
  now = formatdate("YYYYMMDD-hhmmss", timestamp())
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "aws_ssh_username" {
  type    = string
  default = "ubuntu"
}

variable "aws_instance_type" {
  type    = string
  default = "c5n.4xlarge"
}

variable "root_volume_size" {
  type    = number
  default = 350
}

variable "aws_temporary_security_group_source_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

source "amazon-ebs" "crtm_base" {

  profile = "mantari"

  region        = var.aws_region
  instance_type = var.aws_instance_type

  ssh_username = var.aws_ssh_username
  ssh_timeout  = "120m"

  communicator                = "ssh"
  associate_public_ip_address = true

  source_ami = "ami-0e61dd6c08a3d8fde"

  ami_name        = "da-cluster-crtm-${local.now}"
  ami_description = "DA Cluster AMI with CRTM coefficient archive"

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    delete_on_termination = true
    iops                  = 10000
    throughput            = 1000
  }

  temporary_security_group_source_cidrs =
    var.aws_temporary_security_group_source_cidrs

  tags = {
    Name      = "DA-Cluster-CRTM"
    BaseAMI   = "ami-0e61dd6c08a3d8fde"
    CRTM      = "fix_REL-3.1.2.0"
    ManagedBy = "Packer"
  }
}

build {

  name = "crtm-base"

  sources = [
    "source.amazon-ebs.crtm_base"
  ]

  provisioner "file" {
    source      = "/home/jonggyunkim/git/jedi-build/jedi-bundle/test-data-release/fix_REL-3.1.2.0.tgz"
    destination = "/tmp/fix_REL-3.1.2.0.tgz"
  }

  provisioner "shell" {
    inline = [
      "sudo mkdir -p /opt/crtm",
      "sudo mv /tmp/fix_REL-3.1.2.0.tgz /opt/crtm/",
      "sudo chmod 644 /opt/crtm/fix_REL-3.1.2.0.tgz",
      "ls -lh /opt/crtm/"
    ]
  }
}