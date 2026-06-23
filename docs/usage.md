# Usage

## Complete Workflow

The full deployment involves four sequential phases:

| Phase | Duration | What Runs |
|-------|----------|-----------|
| 1. Build base AMI | 25-35 min | `packer build` on your local machine |
| 2. Create cluster | 10-15 min | `pcluster create-cluster` |
| 3. Install FV3-JEDI | 60-90 min | `spack-v210.01.sh` on the head node |
| 4. Snapshot AMI | 5-10 min | `aws ec2 create-image` |

---

## Build Base AMI

Navigate to the packer directory:

```bash
cd packer
```

Initialize Packer plugins (required once):

```bash
packer init .
```

Validate the configuration:

```bash
packer validate build_da_cluster.pkr.hcl
```

Build the AMI:

```bash
packer build build_da_cluster.pkr.hcl
```

Packer prints the AMI ID when complete. Record it; you will need it in the next step.

---

## Create Cluster

Activate the ParallelCluster environment:

```bash
conda activate pcluster311
```

Update `aws/aws_east1.config` with the AMI ID from the previous step:

```yaml
Image:
  Os: ubuntu2204
  CustomAmi: ami-xxxxxxxxxxxxxxxxx   # paste AMI ID here
```

Create the cluster:

```bash
pcluster create-cluster \
    --cluster-name da-cluster \
    --cluster-configuration aws/aws_east1.config
```

Monitor cluster creation (takes 10-15 minutes):

```bash
pcluster list-clusters
```

Describe cluster details:

```bash
pcluster describe-cluster \
    --cluster-name da-cluster
```

Connect once the cluster status is `CREATE_COMPLETE`:

```bash
pcluster ssh \
    --cluster-name da-cluster
```

---

## Install FV3-JEDI

On the cluster head node, run the Spack installer:

```bash
sudo bash scripts/spack-v210.01.sh
```

This installs Spack-Stack 2.1 and builds the complete FV3-JEDI dependency tree. The build takes 60-90 minutes. Monitor progress in the terminal output.

---

## Verify Module Environment

After the Spack install completes, verify the module environment:

Display all available modules:

```bash
module avail
```

Load the JEDI base environment:

```bash
module load jedi-base-env/1.0.0
```

Display currently loaded modules:

```bash
module list
```

You should see `stack-gcc/11.4.0`, `stack-openmpi/5.0.8`, and `jedi-base-env/1.0.0` in the output.

---

## Create FV3-JEDI AMI

Snapshot the configured instance so future clusters can skip the 60-90 minute Spack build.

Find the instance ID of the head node:

```bash
pcluster describe-cluster --cluster-name da-cluster \
    | grep HeadNode -A5
```

Create the AMI:

```bash
aws ec2 create-image \
    --instance-id i-xxxxxxxxxxxxxxxxx \
    --name fv3jedi-spack21 \
    --no-reboot
```

Record the resulting AMI ID. Update `aws/aws_east1.config` with this ID to launch pre-configured clusters in future deployments.

---

## Delete Cluster

```bash
pcluster delete-cluster \
    --cluster-name da-cluster
```

The `/scratch` EBS volume is deleted with the cluster. Move any outputs to S3 first.
