FROM almalinux:9

LABEL author="luca.castaldini@inaf.it, leonardo.baroncelli@inaf.it" \
      version="1.0.0" \
      help="Build this Dockerfile with: \n    > docker build -t basic_layer_for_kafka_receiver ."

# Install dependencies and Python 3.11.11
RUN dnf update -y && \
    dnf -y install wget make gcc openssl-devel git bzip2-devel readline-devel libffi-devel gsl-devel xz-devel sqlite-devel which zlib-devel && \
    dnf install -y gcc-toolset-12 && \
    echo "source /opt/rh/gcc-toolset-12/enable" >> /etc/profile.d/gcc-toolset-12.sh && \
    source /opt/rh/gcc-toolset-12/enable && \
    cd /usr/src && \
    wget https://www.python.org/ftp/python/3.11.11/Python-3.11.11.tar.xz && \
    tar -xvf Python-3.11.11.tar.xz && \
    cd Python-3.11.11 && \
    ./configure --enable-optimizations --prefix=/opt/python3 && \
    make altinstall && \
    rm -f /usr/bin/python3 && \
    ln -s /opt/python3/bin/python3.11 /usr/bin/python3 && \
    ln -s /opt/python3/bin/python3.11 /usr/bin/python && \
    ln -s /opt/python3/bin/pip3.11 /usr/bin/pip3 && \
    ln -s /opt/python3/bin/pip3.11 /usr/bin/pip && \
    /usr/bin/python3 -m pip install --upgrade pip && \
    dnf clean all && \
    rm -rf /usr/src/Python-3.11.11 /usr/src/Python-3.11.11.tar.xz

# Set environment variables
ENV PATH=/opt/python3/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV LD_LIBRARY_PATH=/opt/rh/gcc-toolset-12/root/usr/lib64

