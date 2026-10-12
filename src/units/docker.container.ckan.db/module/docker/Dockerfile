ARG CONTAINER_VERSION
ARG CONTAINER_IMAGE

FROM ${CONTAINER_IMAGE}:${CONTAINER_VERSION}

# Include extra setup scripts (eg datastore)
COPY --chown=postgres:postgres docker-entrypoint-initdb.d /docker-entrypoint-initdb.d
RUN chmod -R 755 /docker-entrypoint-initdb.d