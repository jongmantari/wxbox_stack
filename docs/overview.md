# Overview

WxBox Stack automates the creation of production-grade HPC clusters on AWS pre-loaded with the FV3-JEDI numerical weather prediction framework.

## Purpose

Deploying FV3-JEDI from scratch requires assembling a large software stack: Intel compilers, MPI libraries, math kernels, and dozens of scientific packages managed through Spack. The process is time-consuming, version-sensitive, and difficult to reproduce consistently across teams.

WxBox Stack solves this with infrastructure-as-code tooling that builds versioned AWS AMIs containing the complete environment. Teams can launch a fully-configured cluster from a known-good image rather than rebuilding the stack from scratch each time.

## Key Technologies

| Component | Version | Role |
|-----------|---------|------|
| Packer | >= 1.9 | AMI build automation |
| AWS ParallelCluster | 3.x | HPC cluster management |
| Ubuntu | 22.04 LTS | Base operating system |
| Intel oneAPI | 2024.2 | C/C++/Fortran compilers, Intel MPI, MKL |
| Lmod | 8.7 | Module environment manager |
| CMake | 3.27.9 | Build system |
| Spack-Stack | 2.1 | HPC package manager for JEDI |
| Slurm | (via ParallelCluster) | Job scheduler |

## Current Capabilities

- Build a base HPC AMI containing Intel oneAPI, GCC, Lmod, and CMake via Packer
- Deploy a multi-node AWS ParallelCluster cluster from a declarative YAML configuration
- Install Spack-Stack 2.1 with the complete FV3-JEDI dependency tree on the cluster head node
- Snapshot the fully-configured cluster into a reusable AMI for future deployments

## Supported JEDI Applications

| Application | Status |
|------------|--------|
| FV3-JEDI | Supported |
| MPAS-JEDI | Planned (Phase 5) |
| SOCA | Planned (Phase 5) |
| UFS Weather Model | Planned (Phase 6) |

## Repository Layout

```text
wxbox_stack/
├── aws/
│   └── aws_east1.config           # AWS ParallelCluster cluster definition
├── docs/                          # This documentation
├── packer/
│   └── build_da_cluster.pkr.hcl  # Packer AMI build definition
└── scripts/
    ├── cluster-start-stack-script.sh  # Base software provisioner (runs inside Packer)
    ├── spack-v193.sh                  # Spack-Stack 1.9.3 installer
    ├── spack-v210.sh                  # Spack-Stack 2.1 installer (latest upstream)
    └── spack-v210.01.sh               # Spack-Stack 2.1 installer (pinned release)
```

## Contact

jong@mantari.com
