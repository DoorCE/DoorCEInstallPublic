#!/bin/bash
# This script initializes the database and role using environment variables.
# It uses psql's -v option for safely passing variables.

set -e
set -x

# Check if required environment variables are set (for safety)
if [ -z "$POSTGRES_USER" ] || [ -z "$DB_UDAS_USER" ] || [ -z "$DB_UDAS_PASSWORD" ] || [ -z "$DB_UDAS_NAME" ]; then
  echo "ERROR: One or more required environment variables (POSTGRES_USER, DB_UDAS_USER, DB_UDAS_PASSWORD, DB_UDAS_NAME) are not set."
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

echo "Initializing the database role and database..."

# Call psql passing shell variables via the -v option
# Each -v option sets a psql variable: NAME=VALUE
# We use different psql variable names (e.g., db_user) to avoid potential conflicts
psql -v ON_ERROR_STOP=1 \
     --username "$POSTGRES_USER" \
     -v db_user="$DB_UDAS_USER" \
     -v db_password="$DB_UDAS_PASSWORD" \
     -v db_database="$DB_UDAS_NAME" \
     <<-EOSQL
    -- Create role: Using psql variables
    -- Identifiers (role names, database names) are best quoted using psql syntax :"variable_name"
    -- String literals (passwords) should be quoted using psql syntax :'variable_name' (ensures proper escaping)
    CREATE ROLE :"db_user" NOSUPERUSER CREATEDB CREATEROLE LOGIN PASSWORD :'db_password';
    
    -- Create database: Using psql variables
    CREATE DATABASE :"db_database" OWNER :"db_user" ENCODING 'utf-8';

    -- Optional: Grant privileges
    -- GRANT ALL PRIVILEGES ON DATABASE :"db_database" TO :"db_user"; 
EOSQL

echo "The database and role initialization completed successfully."