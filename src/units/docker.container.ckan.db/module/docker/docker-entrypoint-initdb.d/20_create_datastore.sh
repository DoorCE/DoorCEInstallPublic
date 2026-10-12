#!/bin/bash
# This script initializes the Datastore database and readonly role using environment variables.
# It uses psql's -v option for safely passing variables.

set -e
set -x

# Check if required environment variables are set (for safety)
# Note: Added CKAN_DB_USER check as it's used in the CREATE DATABASE OWNER clause from the original script
if [ -z "$POSTGRES_USER" ] || [ -z "$DATASTORE_READONLY_USER" ] || [ -z "$DATASTORE_READONLY_PASSWORD" ] || [ -z "$DATASTORE_DB" ] || [ -z "$CKAN_DB_USER" ]; then
  echo "ERROR: One or more required environment variables (POSTGRES_USER, DATASTORE_READONLY_USER, DATASTORE_READONLY_PASSWORD, DATASTORE_DB, CKAN_DB_USER) are not set."
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

echo "Initializing Datastore database and readonly role..."

# Call psql passing shell variables via the -v option
# Each -v option sets a psql variable: NAME=VALUE
psql -v ON_ERROR_STOP=1 \
     --username "$POSTGRES_USER" \
     -v ds_user="$DATASTORE_READONLY_USER" \
     -v ds_password="$DATASTORE_READONLY_PASSWORD" \
     -v ds_database="$DATASTORE_DB" \
     -v ckan_owner="$CKAN_DB_USER" \
     <<-EOSQL
    -- Create readonly role: Using psql variables
    -- Use :"var" for identifiers (role/db names) and :'var' for string literals (passwords)
    -- Ensures proper quoting and escaping, preventing SQL injection.
    CREATE ROLE :"ds_user" NOSUPERUSER NOCREATEDB NOCREATEROLE LOGIN PASSWORD :'ds_password';
    
    -- Create datastore database: Using psql variables
    -- Note: Owner is set to the value of CKAN_DB_USER as per the original script's intent
    CREATE DATABASE :"ds_database" OWNER :"ckan_owner" ENCODING 'utf-8';

    -- Optional: Grant connect privileges to the new role on the new database (example)
    -- GRANT CONNECT ON DATABASE :"ds_database" TO :"ds_user";
EOSQL

echo "Datastore database and readonly role initialization completed successfully."