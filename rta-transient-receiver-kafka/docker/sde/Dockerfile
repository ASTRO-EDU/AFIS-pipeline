FROM basic_layer_for_kafka_receiver:latest

LABEL author="luca.castaldini@inaf.it" \
      version="1.0.0" \
      help="Build this Dockerfile with: \n    > docker build -t rta_transient_kafka_receiver_sde .>"

# Creazione dell'utente e configurazione sudo
RUN useradd -m -s /bin/bash gamma && \
    dnf install -y sudo && \
    echo "gamma ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Installazione dei tool di sviluppo e Python
RUN dnf install -y \
        vim \
        nano \
        unzip \
        net-tools \
        iproute \
        hostname && \
    pip install --upgrade pip setuptools wheel && \
    pip install pylint black mypy flake8 autopep8

RUN wget https://dev.mysql.com/get/mysql84-community-release-el9-1.noarch.rpm && \
    dnf localinstall -y mysql84-community-release-el9-1.noarch.rpm && \
    dnf install -y mysql-community-client

# Imposta l'utente e la directory di lavoro
USER gamma
ENV wrkdir=/home/gamma/src
WORKDIR $wrkdir

# Crea la directory di lavoro
RUN mkdir -p "$wrkdir"


# Comando di default e informazioni
CMD ["echo 'Starting instance: $(date)'"]
