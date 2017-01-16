FROM centos:7.2.1511
MAINTAINER Sho Fuji <pockawoooh@gmail.com>


CMD ["--help"]
ENTRYPOINT ["ffmpeg"]

WORKDIR /work

COPY MediaServerStudioEssentials2017.tar.gz /work/

COPY libmfx.pc /work/

COPY sys_analyzer_linux.py_.tgz /work/

COPY SRB4_linux64.zip /work/

ENV TARGET_VERSION=3.2.2 \
    IMMS_VERSION=2017 \
    LIBVA_DRIVERS_PATH=/opt/intel/mediasdk/lib64 \
    LIBVA_DRIVER_NAME=iHD \
    MFX_HOME=/opt/intel/mediasdk \
    PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/opt/intel/opencl

RUN yum install -y --enablerepo=extras epel-release yum-utils && \
    # Install IMSS
    usermod -a -G video root && \
    cd /work && \
    mkdir -p /boot && \
    yum -y -t groupinstall "Development Tools" && \
    imss_deps="kernel-headers kernel-devel bc wget \
               bison ncurses-devel hmaccalc zlib-devel \
               binutils-devel elfutils-libelf-devel \
               rpm-build redhat-rpm-config asciidoc \
               perl-ExtUtils-Embed persign xmlto \
               audit-libs-devel elfutils-devel \
               newt-devel numactl-devel pciutils-devel \
               python-devel mesa-dri-drivers openssl-devel" && \
    yum -y -t install ${imss_deps} && \
    tar -xzf MediaServerStudio*.tar.gz && \
    cd MediaServerStudio* && \
    tar -xzf SDK${IMMS_VERSION}*.tar.gz && \
    cd SDK${IMMS_VERSION}*/Generic && \
    tar -xzf intel-linux-media_generic*.tar.gz && \
    cp -r etc/* /etc && \
    cp -r opt/* /opt && \
    cp -r lib/* /lib && \
    cp -r usr/* /usr && \
    GENERIC_KERNEL_SRC=linux-4.4.tar.xz && \
    GENERIC_KERNEL_WEB_PATH=http://www.kernel.org/pub/linux/kernel/v4.x && \
    wget ${GENERIC_KERNEL_WEB_PATH}/${GENERIC_KERNEL_SRC} && \
    tar -xJf ${GENERIC_KERNEL_SRC} && \
    cp /opt/intel/mediasdk/opensource/patches/kmd/4.4/intel-kernel-patches.tar.bz2 . && \
    tar -xjf intel-kernel-patches.tar.bz2 && \
    cd linux-4.4 && \
    for i in ../intel-kernel-patches/*.patch; do patch -p1 < $i; done && \
    make olddefconfig && make -j 8 && \
    make modules_install && make install && \
    mkdir /opt/intel/mediasdk/include/mfx && \
    cp /opt/intel/mediasdk/include/*.h /opt/intel/mediasdk/include/mfx/ && \
    mv /work/libmfx.pc /usr/lib64/pkgconfig/ && \
    ln -s /opt/intel/mediasdk/include/ /usr/local/include/mfx && \
    cd /work && \
    rm -rf /work/MediaServerStudio* && \
    # Install Intel OpenCL driver
    mkdir /work/intel-opencl && \
    mv /work/SRB4_linux64.zip /work/intel-opencl/ && \
    cd /work/intel-opencl && \
    unzip SRB4_linux64.zip && \
    mkdir intel-opencl && \
    tar -C intel-opencl -Jxf intel-opencl-r4.0-*.x86_64.tar.xz && \
    tar -C intel-opencl -Jxf intel-opencl-devel-r4.0-*.x86_64.tar.xz && \
    tar -C intel-opencl -Jxf intel-opencl-cpu-r4.0-*.x86_64.tar.xz && \
    cp -R intel-opencl/* / && \
    ldconfig && \
    # Install build dependencies
    build_deps="automake autoconf bzip2 \
                cmake freetype-devel gcc \
                gcc-c++ git libtool make \
                mercurial nasm pkgconfig \
                yasm zlib-devel" && \
    yum install -y ${build_deps} && \
    # Build ffmpeg
    DIR=$(mktemp -d) && cd ${DIR} && \
    curl -sL http://ffmpeg.org/releases/ffmpeg-${TARGET_VERSION}.tar.gz | \
    tar -zx --strip-components=1 && \
    ./configure \
        --enable-nonfree \
        --enable-small \
        --enable-gpl \
        --enable-libmfx \
        --disable-doc \
        --disable-debug && \
    make && make install && \
    make distclean && \
    hash -r && \
    # Cleanup build dependencies and temporary files
    rm -rf ${DIR} && \
    yum history -y undo last && \
    yum clean all && \
    ffmpeg -buildconf
