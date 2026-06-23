# Packer Configuration Reference

**File**: `packer/build_da_cluster.pkr.hcl`

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `aws_region` | `us-east-1` | Primary AWS region for the AMI build |
| `instance_type` | `c7i.8xlarge` | EC2 instance type used during provisioning |
| `ssh_keypair_name` | `jong-aws-east1-ed25519` | EC2 key pair name for SSH access during build |
| `ssh_private_key_file` | `~/.ssh/jong-aws-east1-ed25519` | Path to the private key file on your local machine |
| `copy_regions` | `[]` | Additional regions to copy the finished AMI into |

## Source AMI

The build sources from the AWS ParallelCluster 3.15.1 Ubuntu 22.04 LTS base AMI, filtered by name:

```
aws-parallelcluster-3.15.1-ubuntu-2204-lts-hvm-x86_64-*
```

This base image already includes the ParallelCluster agent software, so the resulting AMI is directly compatible with `pcluster create-cluster` without additional setup.

## Root Volume

| Parameter | Value |
|-----------|-------|
| Size | 330 GB |
| Type | gp3 |
| IOPS | 10,000 |
| Throughput | 1,000 Mbps |
| Encryption | Disabled |
| Delete on termination | True |

## AMI Naming

Each build generates a timestamped AMI name to prevent collisions:

```
da-cluster-YYYYMMDD-hhmmss.x86_64-gp3
```

## Provisioner

The build runs a single shell provisioner that executes the base software installation script:

```hcl
provisioner "shell" {
  script = "scripts/cluster-start-stack-script.sh"
}
```

See [Scripts Reference](scripts.md) for details on what this script installs.

## Build Commands

```bash
cd packer

# Initialize Packer plugins (required on first use)
packer init .

# Validate configuration syntax
packer validate build_da_cluster.pkr.hcl

# Build the AMI
packer build build_da_cluster.pkr.hcl
```

Packer prints the AMI ID at completion. Copy it into `aws/aws_east1.config` under `Image.CustomAmi` before creating a cluster.

## SSH Timeout

Packer waits up to 60 minutes for the SSH connection to become available after the instance boots. If you see timeout errors, verify that your security group allows inbound SSH and that the key pair is correct.
