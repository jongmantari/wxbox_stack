# Getting Started

## Prerequisites

### AWS Account

You need an AWS account with IAM permissions to:

- Create, describe, and deregister EC2 instances and AMIs
- Create and manage VPCs, subnets, and security groups
- Create and delete CloudFormation stacks (used by ParallelCluster)
- Attach IAM instance profiles to EC2 instances

An EC2 key pair in `us-east-1` is required for SSH access to the cluster head node. The default config references `jong-aws-east1-ed25519`; update this to your own key pair name before building.

Configure the AWS CLI with your credentials:

```bash
aws configure
```

### Packer

Install Packer on your local machine:

```bash
# macOS
brew tap hashicorp/tap
brew install hashicorp/tap/packer

# Linux (via apt)
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update && sudo apt-get install packer

packer version
```

### AWS ParallelCluster CLI

Install the ParallelCluster CLI in a dedicated Conda environment:

```bash
conda create -n pcluster311 python=3.11 -y
conda activate pcluster311
pip install aws-parallelcluster==3.11

pcluster version
```

## Clone the Repository

```bash
git clone git@github.com:jongmantari/wxbox_stack.git
cd wxbox_stack
```

## Configuration

### Update the SSH Key Name

Edit the Packer variable to match your EC2 key pair:

```hcl
# packer/build_da_cluster.pkr.hcl
variable "ssh_keypair_name" {
  default = "your-keypair-name"
}

variable "ssh_private_key_file" {
  default = "~/.ssh/your-keypair-name"
}
```

Edit the cluster config to match the same key:

```yaml
# aws/aws_east1.config
HeadNode:
  Ssh:
    KeyName: your-keypair-name
```

### Update the AMI ID After Each Packer Build

The cluster config requires the AMI ID produced by Packer. After a successful build, Packer prints the new AMI ID. Update `aws_east1.config`:

```yaml
Image:
  Os: ubuntu2204
  CustomAmi: ami-xxxxxxxxxxxxxxxxx   # Replace with output from packer build
```

## Estimated Durations

| Step | Estimated Duration |
|------|-------------------|
| Packer base AMI build | 25-35 minutes |
| ParallelCluster creation | 10-15 minutes |
| Spack-Stack 2.1 installation | 60-90 minutes |
| AMI snapshot | 5-10 minutes |

## Next Steps

See [Usage](usage.md) for the complete step-by-step workflow.
