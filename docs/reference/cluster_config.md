# Cluster Configuration Reference

**File**: `aws/aws_east1.config`

## Region

```yaml
Region: us-east-1
```

All resources (AMI, VPC, EBS volumes) must reside in the same region.

## Image

```yaml
Image:
  Os: ubuntu2204
  CustomAmi: ami-xxxxxxxxxxxxxxxxx
```

Set `CustomAmi` to the AMI ID output by the most recent Packer build. Using the ParallelCluster base AMI without a custom AMI will produce a cluster without Intel oneAPI or Lmod.

## Head Node

| Parameter | Value | Notes |
|-----------|-------|-------|
| Instance Type | `c7i.8xlarge` | 32 vCPUs, 64 GB RAM; handles Spack builds |
| Root Volume | 500 GB gp3 | 10,000 IOPS, 1,000 Mbps; holds the Spack store |
| SSH Key | `jong-aws-east1-ed25519` | Update to your key pair name |
| IAM Policy: S3FullAccess | Yes | Required for data I/O to S3 |
| IAM Policy: SSMManagedInstanceCore | Yes | Required for ParallelCluster management |

The head node must have sufficient disk space for the Spack store. The default 500 GB accommodates Spack-Stack 2.1 with headroom for FV3-JEDI build artifacts.

## Scheduler

```yaml
Scheduling:
  Scheduler: slurm
```

Slurm is the only supported scheduler. ParallelCluster manages Slurm configuration automatically.

## Compute Queue

| Parameter | Value | Notes |
|-----------|-------|-------|
| Name | `compute` | Used in `sbatch -p compute` |
| Capacity Type | `ONDEMAND` | No spot interruptions |
| Instance Type | `c7i.24xlarge` | 96 vCPUs, 192 GB RAM per node |
| Min Capacity | 0 | Scales to zero when idle (no idle cost) |
| Max Capacity | 2 | Maximum simultaneous compute nodes |
| Placement Group | Enabled | Reduces inter-node latency |
| EFA | Disabled | See note below |

### Enabling EFA

To run tightly-coupled MPI jobs with low-latency networking, switch to an EFA-capable instance type and enable EFA:

```yaml
ComputeResources:
  - Name: compute
    InstanceType: hpc7g.16xlarge
    Efa:
      Enabled: true
```

EFA-capable instance types include `hpc6a.48xlarge`, `hpc7g.16xlarge`, and `c5n.18xlarge`.

## Shared Storage

| Parameter | Value |
|-----------|-------|
| Mount Point | `/scratch` |
| Type | EBS gp3 |
| Size | 500 GB |
| Deletion Policy | Delete |

The `/scratch` volume is mounted on all nodes (head and compute) and deleted when the cluster is deleted. Save any outputs to S3 before running `pcluster delete-cluster`.

## Cluster Management Commands

```bash
# Create cluster
conda activate pcluster311
pcluster create-cluster \
    --cluster-name da-cluster \
    --cluster-configuration aws/aws_east1.config

# Check status
pcluster list-clusters
pcluster describe-cluster --cluster-name da-cluster

# Connect to head node
pcluster ssh --cluster-name da-cluster

# Delete cluster (also deletes /scratch EBS volume)
pcluster delete-cluster --cluster-name da-cluster
```
