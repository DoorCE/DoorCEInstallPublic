ARG IMAGE_NAME
ARG IMAGE_VERSION
ARG SERVICE_SITE_PATH
ARG UDAS_SERVER_URL
ARG KEYCLOAK_PATH
ARG KEYCLOAK_REALM
ARG KEYCLOAK_CLIENT
ARG KEYCLOAK_REDIRECT
ARG KEYCLOAK_CLIENT_SECRET
ARG UDAS_PLATFORM_URL

FROM ${IMAGE_NAME}:${IMAGE_VERSION}
ARG SERVICE_SITE_PATH
ARG UDAS_SERVER_URL
ARG KEYCLOAK_PATH
ARG KEYCLOAK_REALM
ARG KEYCLOAK_CLIENT
ARG KEYCLOAK_REDIRECT
ARG KEYCLOAK_CLIENT_SECRET
ARG UDAS_PLATFORM_URL
RUN apt update && \
    apt install -y --no-install-recommends \
        procps \
        iproute2 \
        iputils-ping \
        curl \
        jq && \
    rm -rf /var/lib/apt/lists/*
RUN [ ! -f /build_info.txt ] && touch /build_info.txt || . /build_info.txt \
    && flutter build web --release \
    --dart-define UDAS_PATH=${UDAS_SERVER_URL} \
    --dart-define UDAS_SERVER_URL=${UDAS_SERVER_URL} \
    --dart-define UDAS_PLATFORM_URL=${UDAS_PLATFORM_URL} \
    --dart-define KEYCLOAK_PATH=${KEYCLOAK_PATH} \
    --dart-define KEYCLOAK_REALM=${KEYCLOAK_REALM} \
    --dart-define KEYCLOAK_CLIENT=${KEYCLOAK_CLIENT} \
	--dart-define KEYCLOAK_REDIRECT=${KEYCLOAK_REDIRECT} \
    --dart-define KEYCLOAK_CLIENT_SECRET=${KEYCLOAK_CLIENT_SECRET} \
    --dart-define BUILD_DATE=${BUILD_DATE} \
    --dart-define DOCKER_TAG=${DOCKER_TAG} \
	--base-href "${SERVICE_SITE_PATH}/"
RUN echo "UDAS_PATH=${UDAS_SERVER_URL}" > /args.txt \
    && echo "UDAS_SERVER_URL=${UDAS_SERVER_URL}" >> /args.txt \
    && echo "UDAS_PLATFORM_URL=${UDAS_PLATFORM_URL}" >> /args.txt