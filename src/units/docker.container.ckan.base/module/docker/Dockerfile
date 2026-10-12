ARG CONTAINER_VERSION
ARG CONTAINER_IMAGE

FROM ${CONTAINER_IMAGE}:${CONTAINER_VERSION}

USER root

RUN cd src/\
    && pip install -e "git+https://github.com/ckan/ckanext-scheming.git#egg=ckanext-scheming" \
    && git clone https://github.com/ckan/ckanext-fluent.git \
    && cd ckanext-fluent \
    && python setup.py develop \
    && pip install -r requirements.txt
    
RUN pip install ckanext-dcat

COPY --chown=ckan-sys:ckan-sys docker-entrypoint.d/* /docker-entrypoint.d/

USER ckan
