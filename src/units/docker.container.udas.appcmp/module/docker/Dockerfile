ARG CONTAINER_VERSION
ARG CONTAINER_IMAGE

FROM ${CONTAINER_IMAGE}:${CONTAINER_VERSION}
USER root
RUN apt update && \
    apt install -y --no-install-recommends \
        curl \
        jq
USER app