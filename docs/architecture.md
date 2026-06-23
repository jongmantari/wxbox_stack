# Architecture

## Current Architecture

```text
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
Running Cluster
        │
        ▼
spack-v210.01.sh
        │
        ▼
FV3-JEDI Environment
        │
        ▼
Manual AMI Snapshot
```

---

## Base Layer

The base AMI installs:

- Ubuntu
- Intel oneAPI
- Intel MPI
- GCC Toolchain
- Git
- Git LFS
- CMake
- Lmod
- Build tools

No JEDI software is installed at this stage.

---

## FV3-JEDI Layer

The FV3-JEDI layer contains:

- Spack Stack 2.1
- Compiler configuration
- MPI configuration
- FV3-JEDI dependencies
- JEDI module environment

---

## Future Architecture

```text
Packer
 ├── Install Base Software
 ├── Install Spack Stack
 ├── Install FV3-JEDI
 ├── Validation
 └── AMI Creation
          │
          ▼
     FV3-JEDI AMI
```

The future design removes all manual software installation steps.