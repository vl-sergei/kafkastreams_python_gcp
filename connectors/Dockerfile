FROM confluentinc/cp-server-connect-operator:6.1.0.0 AS base

USER root

RUN confluent-hub install --no-prompt confluentinc/kafka-connect-gcs-source:1.4.11 \
    && confluent-hub install --no-prompt confluentinc/kafka-connect-gcs:5.5.10

USER user