# https://alpinelinux.org/releases/
ARG OPENTOFU_VERSION=1.10.5
ARG TERRAGRUNT_VERSION=0.93.12
ARG TARGETARCH=amd64
ARG UID=1000
ARG GID=1000
ARG USERNAME=tofu
ARG GROUPNAME=tofu

FROM alpine:3.23

ARG OPENTOFU_VERSION
ARG TERRAGRUNT_VERSION
ARG TARGETARCH
ARG UID
ARG GID
ARG USERNAME
ARG GROUPNAME


# Install dependencies
RUN apk update \
    && apk add --no-cache wget unzip make git docker-cli sudo bash openssh curl ca-certificates jq \
    && update-ca-certificates \
    && wget https://github.com/opentofu/opentofu/releases/download/v${OPENTOFU_VERSION}/tofu_${OPENTOFU_VERSION}_${TARGETARCH}.apk -O tofu.apk \
    && apk add --allow-untrusted tofu.apk \
    && rm -f tofu.apk \
    && wget https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_${TARGETARCH} -O /usr/local/bin/terragrunt \
    && chmod +x /usr/local/bin/terragrunt \
    && terragrunt --version \
    && tofu --version \
    && docker --version

# Create a user and group with the specified UID and GID
RUN env \
    && addgroup -g 483 -S docker || true \
    && addgroup -g ${GID} -S ${GROUPNAME} || true \
    && adduser -u ${UID} -D -S -G ${GROUPNAME} ${USERNAME} || true \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
    && sed -i 's/^#\s*\(Defaults\s\+secure_path\s*=\s*\).*/\1\/usr\/local\/bin:\/usr\/bin:\/bin/' /etc/sudoers

WORKDIR /workspace
RUN git config --global --add safe.directory /workspace