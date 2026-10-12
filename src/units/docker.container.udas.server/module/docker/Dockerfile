ARG IMAGE_NAME
ARG IMAGE_VERSION

FROM ${IMAGE_NAME}:${IMAGE_VERSION}
USER root
RUN apt update && \
    apt install -y --no-install-recommends \
        procps \
        iproute2 \
        iputils-ping \
        curl \
        jq \
        dos2unix && \
    rm -rf /var/lib/apt/lists/*
USER app
