FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
        build-essential \
        gcc-13 \
        g++-13 \
        gfortran-13 \
        git \
        git-lfs \
        wget \
        curl \
        cmake \
        automake \
        autoconf \
        pkg-config \
        python3 \
        python3-pip \
        python3-setuptools \
        tcl-dev \
        gettext \
        libtool \
        flex \
        less \
        unzip \
        bzip2 \
        locales \
        gnupg2 \
        file \
        rsync \
        patch \
        findutils \
        zlib1g-dev \
        libncurses-dev \
        ca-certificates

COPY Docker/scripts /tmp/scripts

RUN chmod +x /tmp/scripts/*.sh

###############################################################################
# Lua 5.1.4.9 + posix+lfs+lpeg
###############################################################################

RUN /tmp/scripts/install_lua.sh

ENV PATH=/opt/lua/bin:${PATH}
ENV LD_LIBRARY_PATH=/opt/lua/lib:${LD_LIBRARY_PATH:-}

RUN which lua && lua -v
RUN which luac

###############################################################################
# Lmod
###############################################################################

RUN /tmp/scripts/install_lmod.sh

###############################################################################
# Verify
###############################################################################

RUN test -f /opt/lmod/lmod/init/profile

###############################################################################
# Spack stack later
###############################################################################

# RUN /tmp/scripts/install_spack_stack.sh

COPY Docker/scripts/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/bin/bash"]