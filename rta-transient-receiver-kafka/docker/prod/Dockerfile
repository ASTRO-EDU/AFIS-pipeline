FROM basic_layer_for_kafka_receiver:latest

LABEL author="leonardo.baroncelli@inaf.it, luca.castaldini@inaf.it, luca.babboni2@studio.unibo.it" \
      version="1.0.0" \
      help="Build this Dockerfile with: \n    > docker build --build-arg -t rta_transient_kafka_receiver_prod ."


ARG REPO_BRANCH=main

RUN python -m pip install --upgrade pip && \
    git clone --recurse-submodules --branch $REPO_BRANCH https://github.com/ASTRO-EDU/rta-transient-receiver-kafka.git && \
    cd rta-transient-receiver-kafka && \
    pip install -r rta-transient-receiver/requirements.lock && \
    pip install -r requirements.txt && \
    pip install -e rta-transient-receiver/ && \
    pip install -e .

RUN mkdir -p /etc/kafkareceiver/conf.d && \
    mkdir -p /var/log/kafkareceiver && \
    chmod -R 755 /etc/kafkareceiver /var/log/kafkareceiver

ENV RECEIVER_LOG_LEVEL=INFO
ENV RECEIVER_LOG_MODE=FILE

WORKDIR /var/log/kafkareceiver

ENTRYPOINT ["/bin/bash", "-c", "kafkareceiver --config-file /etc/kafkareceiver/conf.d/config.json --log-file receiver_$(date +\"%Y_%m_%d__%H:%M:%S\").log"]

# CMD ["echo 'Starting instance: $(date)'"]
