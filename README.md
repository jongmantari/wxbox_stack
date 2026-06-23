# WxBox Stack

WxBox Stack provides a reproducible AWS platform for building and deploying FV3-JEDI development environments using:

- Packer
- AWS EC2
- AWS ParallelCluster
- Intel oneAPI
- Lmod
- Spack Stack

Current support:

- FV3-JEDI
- Spack Stack 2.1
- AWS AMI automation

Future support:

- MPAS-JEDI
- SOCA
- UFS Weather Model

---

# Repository Layout

```text
wxbox_stack/
├── aws/
│   └── aws_east1.config
│
├── docs/
│   ├── architecture.md
│   ├── usage.md
│   └── roadmap.md
│
├── packer/
│   └── build_da_cluster.pkr.hcl
│
├── scripts/
│   ├── cluster-start-stack-script.sh
│   ├── spack-v193.sh
│   ├── spack-v210.sh
│   └── spack-v210.01.sh
│
└── tests/
```

---

# Current Workflow

```text
Packer
    │
    ▼
build_da_cluster.pkr.hcl
    │
    ▼
cluster-start-stack-script.sh
    │
    ▼
Base HPC AMI
    │
    ▼
AWS ParallelCluster
    │
    ▼
aws_east1.config
    │
    ▼
Cluster Deployment
    │
    ▼
spack-v210.01.sh
    │
    ▼
FV3-JEDI Environment
    │
    ▼
Manual AMI Creation
```

---

# Build Base AMI

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

# Create AWS ParallelCluster

Activate environment:

```bash
conda activate pcluster311
```

Create cluster:

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

Connect:

```bash
pcluster ssh \
    --cluster-name da-cluster
```

Delete:

```bash
pcluster delete-cluster \
    --cluster-name da-cluster
```

---

# Install FV3-JEDI

On the cluster head node:

```bash
sudo bash scripts/spack-v210.01.sh
```

This installs:

- Intel oneAPI
- Lmod
- Spack Stack 2.1
- FV3-JEDI environment
- JEDI modulefiles

---

# Create FV3-JEDI AMI

Current workflow:

```bash
aws ec2 create-image \
    --instance-id i-xxxxxxxxxxxxxxxxx \
    --name fv3jedi-spack21 \
    --no-reboot
```

---

# Future Goal

Automate FV3-JEDI AMI creation directly through Packer:

```text
Packer
 ├── cluster-start-stack-script.sh
 └── spack-v210.01.sh
          │
          ▼
      FV3-JEDI AMI
```

Target command:

```bash
packer build build_fv3jedi_ami.pkr.hcl
```

---

# Contact for information

jong@mantari.com