# Usage

## Build Base AMI

Initialize:

```bash
cd packer

packer init .
```

Validate:

```bash
packer validate build_da_cluster.pkr.hcl
```

Build:

```bash
packer build build_da_cluster.pkr.hcl
```

---

## Create Cluster

```bash
conda activate pcluster311
```

```bash
pcluster create-cluster \
    --cluster-name da-cluster \
    --cluster-configuration aws/aws_east1.config
```

---

## Monitor Cluster

```bash
pcluster list-clusters
```

```bash
pcluster describe-cluster \
    --cluster-name da-cluster
```

---

## Connect To Cluster

```bash
pcluster ssh \
    --cluster-name da-cluster
```

---

## Install FV3-JEDI

```bash
sudo bash scripts/spack-v210.01.sh
```

---

## Verify Module Environment

Display available modules:

```bash
module avail
```

Load JEDI environment:

```bash
module load jedi-base-env/1.0.0
```

Display active modules:

```bash
module list
```

---

## Create FV3-JEDI AMI

```bash
aws ec2 create-image \
    --instance-id i-xxxxxxxxxxxxxxxxx \
    --name fv3jedi-spack21 \
    --no-reboot
```

Record the resulting AMI ID for future deployments.