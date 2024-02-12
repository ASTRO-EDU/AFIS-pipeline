FROM kafka_base_layer:latest

LABEL author="luca.castaldini@inaf.it" \
      version="1.0.0" \
      help="Run the Kafka receiver application with: \n    > docker run --rm kafka_receiver <config_file> <output_file>"

# Creazione dell'utente e configurazione sudo
RUN useradd -m -s /bin/bash gamma && \
    dnf install -y sudo && \
    echo "gamma ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Installazione dei tool di sviluppo e Python
RUN dnf install -y \
        vim \
        nano \
        wget \
        unzip \
        net-tools \
        iproute \
        hostname && \
    pip install --upgrade pip setuptools wheel && \
    pip install pylint black mypy flake8 autopep8

# Imposta l'utente e la directory di lavoro
USER gamma
ENV wrkdir=/home/gamma/src
WORKDIR $wrkdir

# Crea la directory di lavoro
RUN mkdir -p "$wrkdir"

# Comando di default e informazioni
CMD ["echo 'Starting instance: $(date)'"]
