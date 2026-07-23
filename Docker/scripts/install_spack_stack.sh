#!/bin/bash
set -e

cd /opt

git clone \
  -b release/2.1 \
  --recursive \
  https://github.com/jcsda/spack-stack.git

cd spack-stack

source setup.sh

spack stack create env \
     --site linux.default \
     --name fv3jedi \
     --compiler gcc

cd envs/fv3jedi

spack env activate .

spack add jedi-fv3-env

spack concretize --force
