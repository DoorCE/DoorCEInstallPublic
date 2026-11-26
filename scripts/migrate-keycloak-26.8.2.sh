#!/usr/bin/env bash
set -euo pipefail

ZONE="${1:?Missing required argument: ZONE}"
CONFIG_FILE="${2:-DoorCEInstallPublic/config.yaml}"
INCUS_INSTANCE="${3:-doorce}"
MARKER_FILE="/opt/keycloak/data/.migrated-26.8.2-kc-admin-api"

MASTER_HOST=$(yq -r --arg z "$ZONE" '.zones[$z].master' "$CONFIG_FILE")
HOST_IP=$(yq -r --arg z "$ZONE" --arg h "$MASTER_HOST" '.zones[$z].members[$h].address' "$CONFIG_FILE")
HOST_USER=$(yq -r --arg z "$ZONE" --arg h "$MASTER_HOST" '.zones[$z].members[$h].user' "$CONFIG_FILE")
SSH_TARGET="${HOST_USER}@${HOST_IP}"

echo "Checking Keycloak migration status for zone '$ZONE' on $SSH_TARGET (incus: $INCUS_INSTANCE)..."

# 1. Check if Incus instance and keycloak.data volume exist (fresh install -> skip)
if ! ssh "$SSH_TARGET" "incus info '$INCUS_INSTANCE' >/dev/null 2>&1"; then
  echo "Incus instance '$INCUS_INSTANCE' does not exist yet (fresh install) - skipping migration."
  exit 0
fi

if ! ssh "$SSH_TARGET" "incus exec '$INCUS_INSTANCE' -- docker volume inspect keycloak.data >/dev/null 2>&1"; then
  echo "Volume 'keycloak.data' does not exist (fresh install) - skipping migration."
  exit 0
fi

# 2. Check if H2 database exists and whether the migration marker is already present
NEED_MIGRATION=$(ssh "$SSH_TARGET" "incus exec '$INCUS_INSTANCE' -- docker run --rm --entrypoint /bin/sh \
  -v keycloak.data:/opt/keycloak/data keycloak:26.8.2 -c '
    if [ ! -f /opt/keycloak/data/h2/keycloakdb.mv.db ]; then
      echo skip_empty
    elif [ -f $MARKER_FILE ]; then
      echo skip_done
    else
      echo migrate
    fi
  '" | tr -d '\r')

if [ "$NEED_MIGRATION" != "migrate" ]; then
  echo "Migration not required (status: $NEED_MIGRATION)."
  exit 0
fi

echo "Detected Keycloak 26.8.1 database without kc-admin-api migration. Running one-time migration..."

ssh "$SSH_TARGET" "incus exec '$INCUS_INSTANCE' -- sh -s" <<'EOF'
set -e

WAS_RUNNING=0
if [ "$(docker inspect -f "{{.State.Running}}" keycloak 2>/dev/null)" = "true" ]; then
  WAS_RUNNING=1
  docker stop keycloak >/dev/null
fi

docker run --rm --entrypoint /bin/sh -v keycloak.data:/opt/keycloak/data keycloak:26.8.2 -c '
  set -e
  TMP_PASS=$(tr -dc "A-Za-z0-9" < /dev/urandom | head -c 32)
  export TMP_PASS

  /opt/keycloak/bin/kc.sh bootstrap-admin service \
    --db=dev-file \
    --client-id=tmp-cli \
    --client-secret:env=TMP_PASS

  /opt/keycloak/bin/kc.sh start \
    --db=dev-file \
    --http-enabled=true \
    --hostname-strict=false \
    --http-relative-path=/keycloak &
  PID=$!

  for i in $(seq 1 45); do
    curl -sf http://localhost:8080/keycloak/realms/master >/dev/null 2>&1 && break
    sleep 2
  done

  API="http://localhost:8080/keycloak/admin/realms/master"
  TOK=$(curl -sf -X POST "http://localhost:8080/keycloak/realms/master/protocol/openid-connect/token" \
    -d "grant_type=client_credentials" \
    -d "client_id=tmp-cli" \
    -d "client_secret=$TMP_PASS" | jq -r .access_token)
  AUTH="Authorization: Bearer $TOK"

  CID=$(jq -r ".clients[0].clientId" /opt/keycloak/data/import/realm-master.json)
  CUUID=$(curl -sf -H "$AUTH" "$API/clients?clientId=$CID" | jq -r ".[0].id")
  SUUID=$(curl -sf -H "$AUTH" "$API/client-scopes" | jq -r ".[] | select(.name==\"kc-admin-api\") | .id")

  curl -sf -X PUT -H "$AUTH" "$API/clients/$CUUID/default-client-scopes/$SUUID"

  ID=$(curl -sf -H "$AUTH" "$API/clients?clientId=tmp-cli" | jq -r ".[0].id // empty")
  [ -n "$ID" ] && curl -sf -X DELETE -H "$AUTH" "$API/clients/$ID"

  touch /opt/keycloak/data/.migrated-26.8.2-kc-admin-api
  kill -TERM $PID
  wait $PID || true
'

if [ "$WAS_RUNNING" -eq 1 ]; then
  docker start keycloak >/dev/null
fi
EOF

echo "Keycloak migration completed successfully."