# Roadmap

## Phase 1 — Base Infrastructure

**Status**: Complete

Build a repeatable base HPC AMI via Packer containing the compiler toolchain, MPI, and module system.

Components:

- Packer automation
- Ubuntu 22.04 LTS
- Intel oneAPI 2024.2 (compilers + MPI + MKL)
- GCC toolchain
- Lmod module manager
- CMake, build tools

Output: Base HPC AMI

---

## Phase 2 — AWS ParallelCluster

**Status**: Complete

Deploy a multi-node HPC cluster on AWS with Slurm job scheduling.

Components:

- AWS ParallelCluster 3.x
- Slurm scheduler
- Shared `/scratch` EBS storage
- Head node: c7i.8xlarge
- Compute nodes: c7i.24xlarge (0-2)

Output: Running Cluster

---

## Phase 3 — FV3-JEDI Environment

**Status**: Complete

Install the complete FV3-JEDI dependency stack on the cluster head node using Spack-Stack 2.1.

Components:

- Spack-Stack 2.1
- FV3-JEDI dependency tree
- Compiler and MPI configuration
- JEDI Lmod module files

Output: FV3-JEDI Runtime Environment

---

## Phase 4 — Automated FV3-JEDI AMI

**Status**: In Progress

Eliminate the manual software installation and AMI snapshot steps. A single `packer build` command will produce the complete FV3-JEDI AMI.

Goal:

```text
Packer
    |
    +-- Base Stack
    +-- Spack-Stack 2.1
    +-- FV3-JEDI
    +-- Validation
          |
          v
      FV3-JEDI AMI
```

Desired outcome:

- No manual software installation on cluster head node
- No manual `aws ec2 create-image` step

Single command:

```bash
packer build build_fv3jedi_ami.pkr.hcl
```

---

## Phase 5 — Additional JEDI Applications

**Status**: Planned

Extend the stack to support additional JEDI applications on the same cluster infrastructure.

Planned applications:

- 2D Analysis from nc files
- MPAS-JEDI
- SOCA

---

## Phase 6 — UFS Weather Model

**Status**: Planned

Add a build environment for the Unified Forecast System (UFS) Weather Model.

Planned components:

- UFS build environment
- Regression testing suite
- UFS development platform

---

## Phase 7 — Local Development Platform

**Status**: Planned

Enable local development workflows using WSL on developer workstations, reducing AWS dependency for day-to-day development.

Target environment:

```text
WSL
  |
  +-- Intel oneAPI
  +-- Lmod
  +-- Spack-Stack
  +-- FV3-JEDI
```

Use cases:

- Local compiler testing
- Spack environment validation
- Development without AWS access
