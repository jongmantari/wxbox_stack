# Architecture

## Current Architecture

The deployment pipeline consists of two independently managed layers, each producing an AMI artifact.

```text
Packer (local)
       |
       v
cluster-start-stack-script.sh
       |
       v
  Base HPC AMI
       |
       v
AWS ParallelCluster
       |
       v
  aws_east1.config
       |
       v
  Running Cluster
       |
       v
  spack-v210.01.sh  (runs on head node)
       |
       v
FV3-JEDI Environment
       |
       v
Manual AMI Snapshot
```

---

## Base Layer

The base AMI is built by Packer and contains the compiler toolchain and module system. No JEDI software is present at this stage.

| Component | Version | Notes |
|-----------|---------|-------|
| Ubuntu | 22.04 LTS | Base OS from ParallelCluster 3.15.1 image |
| GCC toolchain | System | gcc, g++, gfortran |
| Intel oneAPI | 2024.2 | icx, icpx, ifx, Intel MPI, MKL |
| CMake | 3.27.9 | Build system |
| Lmod | 8.7 | Module environment manager |
| Git, Git LFS | Latest | Source control |
| Build tools | System | autotools, make, cmake |

The base layer is stable and changes infrequently. Rebuild it when upgrading Intel oneAPI or Lmod.

---

## FV3-JEDI Layer

The FV3-JEDI layer is installed on a running cluster head node via the Spack installer scripts. It contains the complete dependency tree for FV3-JEDI applications.

| Component | Version | Notes |
|-----------|---------|-------|
| Spack-Stack | 2.1 | HPC package manager |
| Compiler config | oneAPI 2024.2.1 | Registered as Spack compiler |
| Intel MPI | 2024.2.1 | Defined as external package |
| MKL | 2024.2.1 | Defined as external package |
| FV3-JEDI deps | (from spack env) | All packages in `fv3jedi` template |
| JEDI modules | via Lmod | stack-gcc, stack-openmpi, jedi-base-env |

---

## AMI Strategy

| AMI | Contents | When to Rebuild |
|-----|----------|----------------|
| Base HPC AMI | Ubuntu + compilers + Lmod | Intel oneAPI upgrade, Lmod upgrade |
| FV3-JEDI AMI | Base + Spack-Stack 2.1 + FV3-JEDI | Spack-Stack version change, JEDI updates |

The FV3-JEDI AMI allows new clusters to skip the 60-90 minute Spack build. New team members can launch a fully-configured environment in under 20 minutes.

---

## Future Architecture

The target design eliminates the manual software installation and AMI snapshot steps. A single Packer build will produce the complete FV3-JEDI AMI:

```text
Packer (local)
  |
  +-- cluster-start-stack-script.sh  (base layer)
  +-- spack-v210.01.sh               (FV3-JEDI layer)
  +-- validation script
  |
  v
FV3-JEDI AMI  (no manual steps)
```

Target command:

```bash
packer build build_fv3jedi_ami.pkr.hcl
```

This is the goal of [Phase 4](roadmap.md) on the roadmap.
