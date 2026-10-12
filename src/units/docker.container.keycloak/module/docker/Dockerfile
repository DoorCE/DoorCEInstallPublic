ARG CONTAINER_VERSION
ARG CONTAINER_IMAGE

# https://www.keycloak.org/server/containers#_installing_additional_rpm_packages
FROM registry.access.redhat.com/ubi9:latest AS builder
RUN mkdir -p /mnt/rootfs
RUN dnf install --installroot /mnt/rootfs curl gzip jq --releasever 9 --setopt install_weak_deps=false --nodocs -y \
    && dnf --installroot /mnt/rootfs clean all \
    && rpm --root /mnt/rootfs -e --nodeps setup


FROM ${CONTAINER_IMAGE}:${CONTAINER_VERSION}
COPY --from=builder /mnt/rootfs/ /

USER root
RUN mkdir -p /opt/keycloak/data/import && chown -R keycloak:root /opt/keycloak/data/import

USER keycloak