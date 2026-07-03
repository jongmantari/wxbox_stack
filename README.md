# WxBox Stack

WxBox Stack provides reproducible AWS environments for FV3-JEDI development and experimentation.

The project automates creation of:

- DA Cluster AMI
- CRTM Base AMI
- JEDI Bundle AMI
- AWS ParallelCluster environments

using:

- AWS EC2
- AWS ParallelCluster
- Packer
- Spack Stack 2.1
- FV3-JEDI
- Lmod

---

# Architecture

```text
Ubuntu 24.04
      │
      ▼
DA Cluster AMI
      │
      ▼
CRTM Base AMI
      │
      ▼
JEDI Bundle AMI
      │
      ▼
AWS ParallelCluster
      │
      ▼
User Workflows
```

---

# Documentation

- docs/getting-started.md — New user quickstart
- docs/architecture.md — System architecture
- docs/ami-catalog.md — Available AMIs
- docs/build-guide.md — AMI build process
- docs/user-guide.md — FV3-JEDI environment usage and module loading
- docs/roadmap.md — Project roadmap
---

# Quick Start

Configure AWS:

```bash
aws configure --profile mantari

AWS_PROFILE=mantari aws sts get-caller-identity
```

Create cluster:

```bash
pcluster create-cluster \
    --cluster-name da-cluster \
    --cluster-configuration aws/aws_east1.config
```

Connect:

```bash
pcluster ssh \
    --cluster-name da-cluster
```

Load JEDI:

```bash
module use ~/modulefiles

module load jedi/5a0d925
```

Verify:

```bash
which fv3jedi_var.x
```

---

# Contact

jong@mantari.com
`