#!/bin/bash

if [ -f /opt/lmod/lmod/init/profile ]; then
    source /opt/lmod/lmod/init/profile
fi

exec "$@"
