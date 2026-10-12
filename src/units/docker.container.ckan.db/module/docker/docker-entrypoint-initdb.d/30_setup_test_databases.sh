#!/bin/bash
set -e
set -x

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE DATABASE ckan_test OWNER "$CKAN_DB_USER" ENCODING 'utf-8';
    CREATE DATABASE datastore_test OWNER "$CKAN_DB_USER" ENCODING 'utf-8';
EOSQL


#!/bin/bash
# This script initializes the CKAN and Datastore test databases using environment variables.
# It uses psql's -v option for safely passing the owner variable.

set -e

# Check if required environment variables are set (for safety)
if [ -z "$POSTGRES_USER" ] || [ -z "$CKAN_DB_USER" ]; then
  echo "ERROR: One or more required environment variables (POSTGRES_USER, CKAN_DB_USER) are not set."
  exit 1
fi

# --- Wait loop for PostgreSQL readiness ---
echo "Waiting for PostgreSQL server to become available..."
# Use 'postgres' as the default database for the readiness check
# Assumes POSTGRES_USER can connect to the 'postgres' database
until psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname postgres -c '\q' &>/dev/null; do
  >&2 echo "PostgreSQL is unavailable - sleeping"
  sleep 1
done
>&2 echo "PostgreSQL is up - continuing with initialization."
# --- End wait loop ---

echo "Initializing CKAN and Datastore test databases..."

# Call psql passing the CKAN_DB_USER shell variable via the -v option
# Each -v option sets a psql variable: NAME=VALUE
psql -v ON_ERROR_STOP=1 \
     --username "$POSTGRES_USER" \
     -v ckan_owner="$CKAN_DB_USER" \
     <<-EOSQL
    -- Create ckan_test database: Using psql variable for OWNER
    -- Database name 'ckan_test' is hardcoded here.
    -- Use :"var" for identifiers to ensure correct handling
    CREATE DATABASE ckan_test OWNER :"ckan_owner" ENCODING 'utf-8';
    
    -- Create datastore_test database: Using psql variable for OWNER
    -- Database name 'datastore_test' is hardcoded here.
    CREATE DATABASE datastore_test OWNER :"ckan_owner" ENCODING 'utf-8';

    -- Optional: Grant privileges if needed (example)
    -- GRANT ALL PRIVILEGES ON DATABASE ckan_test TO :"ckan_owner";
    -- GRANT ALL PRIVILEGES ON DATABASE datastore_test TO :"ckan_owner";
EOSQL

echo "CKAN and Datastore test databases initialization completed successfully."