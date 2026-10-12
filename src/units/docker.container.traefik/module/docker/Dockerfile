ARG CONTAINER_VERSION
ARG CONTAINER_IMAGE

FROM ${CONTAINER_IMAGE}:${CONTAINER_VERSION}

RUN apk add curl
COPY boot.sh /boot.sh
RUN chmod +x /boot.sh

ENTRYPOINT ["/boot.sh"]
CMD ["traefik"]
