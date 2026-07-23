#!/bin/bash

source /opt/lmod/lmod/init/profile

if [ -d /opt/spack-stack ]; then
    source /opt/spack-stack/setup.sh
fi

exec "$@"
