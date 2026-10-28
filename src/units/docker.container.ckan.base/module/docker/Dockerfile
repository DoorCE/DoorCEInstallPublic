ARG CONTAINER_VERSION
ARG CONTAINER_IMAGE

FROM ${CONTAINER_IMAGE}:${CONTAINER_VERSION}

USER root

# Instalacja git (dla pip) oraz wget i curl (dla healthchecka)
RUN apt-get update && \
    apt-get install -y --no-install-recommends git wget curl && \
    rm -rf /var/lib/apt/lists/*

# Instalacja rozszerzeń CKAN
RUN pip install --no-cache-dir \
    -e "git+https://github.com/ckan/ckanext-scheming.git#egg=ckanext-scheming" \
    -e "git+https://github.com/ckan/ckanext-fluent.git#egg=ckanext-fluent" \
    ckanext-dcat

COPY --chown=ckan-sys:ckan-sys docker-entrypoint.d/* /docker-entrypoint.d/

USER ckan