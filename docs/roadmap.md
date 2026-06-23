# Roadmap

## Phase 1 — Base Infrastructure

Status: Complete

Components:

- Packer
- Ubuntu
- Intel oneAPI
- Intel MPI
- GCC
- Lmod
- Build tools

Output:

```text
Base HPC AMI
```

---

## Phase 2 — AWS ParallelCluster

Status: Complete

Components:

- ParallelCluster
- Slurm
- AWS infrastructure

Output:

```text
Running Cluster
```

---

## Phase 3 — FV3-JEDI Environment

Status: Complete

Components:

- Spack Stack 2.1
- FV3-JEDI dependencies
- Compiler configuration
- JEDI modules

Output:

```text
FV3-JEDI Runtime Environment
```

---

## Phase 4 — Automated FV3-JEDI AMI

Status: In Progress

Goal:

```text
Packer
    │
    ├── Base Stack
    ├── Spack Stack 2.1
    └── FV3-JEDI
          │
          ▼
      Final AMI
```

Desired result:

- No manual software installation
- No manual AMI snapshot process

Single command:

```bash
packer build build_fv3jedi_ami.pkr.hcl
```

---

## Phase 5 — Additional JEDI Applications

Planned:

- MPAS-JEDI
- SOCA

---

## Phase 6 — UFS Weather Model

Planned:

- UFS build environment
- Regression testing
- Development platform

---

## Phase 7 — Local Development Platform

Target:

```text
WSL
    │
    ├── Intel oneAPI
    ├── Lmod
    ├── Spack Stack
    └── FV3-JEDI
```

Purpose:

- Local development
- Compiler testing
- Spack validation
- Reduced AWS dependency