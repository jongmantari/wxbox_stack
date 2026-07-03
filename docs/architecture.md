# Architecture

## Software Layers

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
ParallelCluster
     │
     ▼
User Applications
```

---

# DA Cluster AMI

AMI:

```text
ami-0e61dd6c08a3d8fde
```

Contents:

- Spack Stack 2.1
- GCC 13.3.0
- OpenMPI 5.0.8
- FV3-JEDI Environment
- Lmod

Installed under:

```text
/opt/spack-stack
```

---

# CRTM Base AMI

AMI:

```text
ami-04adc9a7b3950ead0
```

Additional contents:

```text
/opt/crtm/fix_REL-3.1.2.0.tgz
```

Purpose:

- Avoid CRTM network downloads
- Improve JEDI build reproducibility

---

# JEDI Bundle AMI

AMI:

```text
ami-012ebeacdf51b071c
```

Bundle commit:

```text
5a0d9257a258b9954a44593285df20add0d6416d
```

Installed location:

```text
/opt/jedi-bundle
```

---

# ParallelCluster

Cluster configuration:

```text
aws/aws_east1.config
```

Provides:

- Head node
- Slurm scheduler
- Elastic compute nodes
- Shared scratch storage