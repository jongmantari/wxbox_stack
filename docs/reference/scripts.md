# Scripts Reference

## cluster-start-stack-script.sh

**Purpose**: Base layer provisioner executed by Packer during AMI creation.

**Installs**:

| Package | Version | Purpose |
|---------|---------|---------|
| gcc, g++, gfortran, gdb | System | C/C++/Fortran toolchain |
| build-essential, automake, autotools | System | Make, Autotools |
| git, git-lfs | Latest | Source control |
| CMake | 3.27.9 | Build system |
| Lmod | 8.7 | Module environment manager |
| lua5.3, tcl | System | Lmod runtime dependencies |
| libkrb5-dev, libcurl4-openssl-dev, libssl-dev | System | Required by JEDI packages |
| Intel oneAPI Base Kit | 2024.2 | icx (C), icpx (C++), MKL |
| Intel oneAPI HPC Kit | 2024.2 | ifx (Fortran), Intel MPI |

**Output**: A base HPC AMI with compilers, MPI, a module system, and build tools. No JEDI software is installed at this stage.

**Lmod module path**: `/opt/modulefiles`

**Intel oneAPI installation path**: `/opt/intel/oneapi`

---

## spack-v210.01.sh

**Purpose**: Installs Spack-Stack 2.1 (pinned release) and the FV3-JEDI environment on a running cluster head node.

**Usage**:

```bash
sudo bash scripts/spack-v210.01.sh
```

**Installation path**: `/opt/spack-stack-2.1`

**Process**:

1. Clones `spack-stack` at the `release/2.1` tag
2. Patches upstream Spack v0.23 for compatibility
3. Registers the Intel oneAPI 2024.2.1 compiler (`icx`, `icpx`, `ifx`) with Spack
4. Writes site configuration files (`compilers.yaml`, `packages.yaml`) to `configs/sites/linux.default`
5. Creates a `fv3jedi-2.1` Spack environment using the `fv3jedi` template
6. Patches `core_compilers` and `dpcpp` references in the generated environment YAML
7. Concretizes the dependency graph: `spack concretize --force`
8. Builds all packages: `spack install --fail-fast --show-log-on-error`
9. Refreshes Lmod module files and meta-modules

**External packages** (not built from source):

| Package | Version | Path |
|---------|---------|------|
| intel-oneapi-mpi | 2024.2.1 | `/opt/intel/oneapi/mpi/latest` |
| mkl | 2024.2.1 | `/opt/intel/oneapi/mkl/latest` |

**Resulting modules**:

```bash
module load stack-gcc/11.4.0
module load stack-openmpi/5.0.8
module load jedi-base-env/1.0.0
```

**Notes**: This script pins the release tag for reproducibility. Use `spack-v210.sh` to track the latest upstream patch releases.

---

## spack-v210.sh

**Purpose**: Installs Spack-Stack 2.1 (latest upstream) with FV3-JEDI.

Functionally equivalent to `spack-v210.01.sh` but clones the HEAD of the `release/2.1` branch rather than a specific tagged release. Use this when Spack-Stack has released a patch that fixes a build failure.

**Usage**:

```bash
sudo bash scripts/spack-v210.sh
```

**Key differences from `spack-v210.01.sh`**:

- Clones latest upstream rather than a pinned tag
- Uses `jedi-fv3-env` meta-package directly rather than creating it from a template
- Simpler patching approach (fewer post-concretize fixes needed)

---

## spack-v193.sh

**Purpose**: Installs Spack-Stack 1.9.3 with FV3-JEDI. Use when compatibility with the 1.9.3 release is required.

**Usage**:

```bash
sudo bash scripts/spack-v193.sh
```

**Installation path**: `/opt/spack-stack-1.9.3`

**Key differences from the 2.1 scripts**:

| Attribute | 1.9.3 | 2.1 |
|-----------|-------|-----|
| Site config path | `configs/sites/tier2/linux.default` | `configs/sites/linux.default` |
| GCC handling | Removes `gcc@12.3.0` to avoid conflicts | No removal needed |
| External packages | Defines broader set (autoconf, automake, gawk, git) | Minimal externals |
| Meta-package | `jedi-fv3-env` (direct) | Created from template or direct |
| Meta-modules | Not configured | Configured |
