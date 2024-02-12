FROM kafka_base_layer:latest

LABEL author="leonardo.baroncelli@inaf.it, luca.castaldini@inaf.it, luca.babboni2@studio.unibo.it" \
      version="1.0.0" \
      help="Run the Kafka receiver application with: \n    > docker run --rm kafka_receiver <config_file> <output_file>"


ARG REPO_BRANCH=main

RUN python3 -m venv /opt/venv/kafka && \
    source /opt/venv/kafka/bin/activate && \
    /opt/venv/kafka/bin/python3 -m pip install --upgrade pip && \
    cd /opt && \
    rm -rf rta-transient-receiver-kafka/ && \
    git clone --recurse-submodules --branch $REPO_BRANCH https://github.com/ASTRO-EDU/rta-transient-receiver-kafka.git && \
    cd rta-transient-receiver-kafka && \
    pip install -r rta-transient-receiver/requirements.lock && \
    pip install -r requirements.txt && \
    pip install -e rta-transient-receiver/ && \
    pip install -e .

RUN mkdir -p /etc/kafkareceiver/conf.d && \
    mkdir -p /var/log/kafkareceiver && \
    chmod -R 755 /etc/kafkareceiver /var/log/kafkareceiver

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["echo 'Starting instance: $(date)'"]
