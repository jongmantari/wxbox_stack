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
  default = "c5n.9xlarge"
}

variable "root_volume_size" {
  type    = number
  default = 500
}

variable "aws_temporary_security_group_source_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

source "amazon-ebs" "jedi_bundle" {

  # IMPORTANT: Use the AWS profile that owns the DA cluster AMI
  profile = "mantari"

  region        = var.aws_region
  instance_type = var.aws_instance_type

  ssh_username = var.aws_ssh_username
  ssh_timeout  = "120m"

  communicator                = "ssh"
  associate_public_ip_address = true

  # Existing DA Cluster AMI
  source_ami = "ami-0e61dd6c08a3d8fde"

  ami_name        = "jedi-bundle-${local.now}"
  ami_description = "JEDI Bundle build based on DA Cluster AMI"

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    delete_on_termination = true
    iops                  = 10000
    throughput            = 1000
  }

  temporary_security_group_source_cidrs = var.aws_temporary_security_group_source_cidrs

  tags = {
    Name          = "JEDI-Bundle"
    BaseAMI       = "ami-0e61dd6c08a3d8fde"
    Stack         = "fv3-jedi-2.1"
    BundleCommit  = "5a0d9257a258b9954a44593285df20add0d6416d"
    BuiltByPacker = "true"
  }
}

build {

  name = "jedi-bundle-ami"

  sources = [
    "source.amazon-ebs.jedi_bundle"
  ]

  provisioner "file" {
    source      = "${path.root}/../scripts/build_jedi_bundle.sh"
    destination = "/tmp/build_jedi_bundle.sh"
  }

  provisioner "shell" {
    inline = [
      "chmod +x /tmp/build_jedi_bundle.sh",
      "mkdir -p /opt",
      "/tmp/build_jedi_bundle.sh /opt/jedi-bundle"
    ]
  }

  provisioner "shell" {
    inline = [
      "echo '===== Installed JEDI Bundle ====='",
      "ls -ld /opt/jedi-bundle",
      "du -sh /opt/jedi-bundle || true"
    ]
  }
}