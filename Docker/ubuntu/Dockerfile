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
        llvm-14 \
        less \
        unzip \
        bzip2 \
        locales \
        gnupg2 \
        file

COPY scripts /tmp/scripts

RUN chmod +x /tmp/scripts/*.sh

RUN /tmp/scripts/install_lua.sh

RUN /tmp/scripts/install_lmod.sh

RUN /tmp/scripts/install_spack_stack.sh

COPY scripts/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/bin/bash"]