# Build Guide

This document describes how to create all AMIs used by WxBox Stack.

---

# Build Order

```text
build_da_cluster.pkr.hcl
        │
        ▼
build_crtm_base.pkr.hcl
        │
        ▼
build_jedi_bundle.pkr.hcl
```

---

# Build DA Cluster AMI

```bash
packer init packer/build_da_cluster.pkr.hcl

packer validate packer/build_da_cluster.pkr.hcl

packer build packer/build_da_cluster.pkr.hcl
```

Output:

```text
DA Cluster AMI
```

---

# Build CRTM Base AMI

Uploads:

```text
fix_REL-3.1.2.0.tgz
```

Build:

```bash
packer validate packer/build_crtm_base.pkr.hcl

packer build packer/build_crtm_base.pkr.hcl
```

Output:

```text
CRTM Base AMI
```

---

# Build JEDI Bundle AMI

Build:

```bash
packer validate packer/build_jedi_bundle.pkr.hcl

packer build packer/build_jedi_bundle.pkr.hcl
```

Output:

```text
JEDI Bundle AMI
```

Bundle commit:

```text
5a0d9257a258b9954a44593285df20add0d6416d
```

---

# Packer Profiles

Current profile:

```hcl
profile = "mantari"
```

Verify:

```bash
AWS_PROFILE=mantari aws sts get-caller-identity
```