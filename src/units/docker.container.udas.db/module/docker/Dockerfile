ARG IMAGE_NAME
ARG IMAGE_VERSION

FROM ${IMAGE_NAME}:${IMAGE_VERSION}

RUN apt update && \
    apt install -y --no-install-recommends \
        procps \
        iproute2 \
        iputils-ping \
        curl \
        jq \
        dos2unix && \
    rm -rf /var/lib/apt/lists/*
# Include extra setup scripts (eg datastore)
COPY --chown=postgres:postgres docker-entrypoint-initdb.d /docker-entrypoint-initdb.d
RUN dos2unix /docker-entrypoint-initdb.d/10_create_udas_server.sh
RUN chmod -R 755 /docker-entrypoint-initdb.d