# User Guide

## Load FV3-JEDI Environment

```bash
module use ~/modulefiles

module load jedi/5a0d925
```

---

# Module Actions

The JEDI module automatically loads:

```text
stack-gcc/13.3.0
stack-openmpi/5.0.8
jedi-fv3-env/1.0.0
```

and sets:

```text
JEDI_BUNDLE_ROOT
PATH
LD_LIBRARY_PATH
```

---

# Verify Environment

```bash
module list
```

```bash
echo $JEDI_BUNDLE_ROOT
```

Expected:

```text
/opt/jedi-bundle/jedi-bundle/build
```

---

# JEDI Executables

List available executables:

```bash
ls $JEDI_BUNDLE_ROOT/bin
```

Examples:

```bash
fv3jedi_var.x

coupling_forecast_fv3_mom6.x

coupling_interp_fv3_mom6.x

coupling_hofx3d_fv3_mom6.x
```

Locate executable:

```bash
which fv3jedi_var.x
```

---

# CRTM Cache

Location:

```text
/opt/crtm/fix_REL-3.1.2.0.tgz
```

Purpose:

- Faster builds
- Reproducible builds
- No external CRTM download

---

# Unload Environment

```bash
module unload jedi/5a0d925
```

Clear everything:

```bash
module purge
```