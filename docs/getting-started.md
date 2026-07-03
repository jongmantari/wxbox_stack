# Getting Started

This guide walks through creating a ParallelCluster using the prebuilt JEDI Bundle AMI.

---

# Prerequisites

## Create Conda Environment

```bash
conda create -n pcluster311 python=3.11
conda activate pcluster311
```

---

## Install AWS CLI

```bash
pip install awscli
```

Verify:

```bash
aws --version
```

---

## Install AWS ParallelCluster

```bash
pip install aws-parallelcluster
```

Verify:

```bash
pcluster version
```

---

## Install Packer

Verify:

```bash
packer version
```

Required:

```text
>= 1.9.0
```

---

# Configure AWS

```bash
aws configure --profile mantari
```

Verify:

```bash
AWS_PROFILE=mantari aws sts get-caller-identity
```

Expected account:

```text
334566771276
```

---

# Available AMIs

## DA Cluster

```text
ami-0e61dd6c08a3d8fde
```

---

## CRTM Base

```text
ami-04adc9a7b3950ead0
```

---

## JEDI Bundle

```text
ami-012ebeacdf51b071c
```

---

# Create Cluster

```bash
pcluster create-cluster \
    --cluster-name da-cluster \
    --cluster-configuration aws/aws_east1.config
```

Monitor:

```bash
pcluster list-clusters
```

Describe:

```bash
pcluster describe-cluster \
    --cluster-name da-cluster
```

---

# Connect

```bash
pcluster ssh \
    --cluster-name da-cluster
```

---

# Load FV3-JEDI

```bash
module use ~/modulefiles

module load jedi/5a0d925
```

Verify:

```bash
echo $JEDI_BUNDLE_ROOT

which fv3jedi_var.x
```