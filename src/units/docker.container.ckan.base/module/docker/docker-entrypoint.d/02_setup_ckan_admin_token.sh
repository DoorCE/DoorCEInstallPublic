#!/bin/bash -x

if [ "$(ckan -c "$CKAN_INI" user token list $CKAN_SYSADMIN_NAME 2>/dev/null | grep $CKAN_SYSADMIN_NAME)" == "" ]; then
   echo "Set up api_token for $CKAN_SYSADMIN_NAME"
   TOKEN=$(ckan -c $CKAN_INI user token add $CKAN_SYSADMIN_NAME $CKAN_SYSADMIN_NAME | tail -n 1 | tr -d '\t')
   install -m 600 /dev/null $CKAN_ADMIN_API_TOKEN_PATH && echo "$TOKEN" > $CKAN_ADMIN_API_TOKEN_PATH
fi
echo "api_token for $CKAN_SYSADMIN_NAME already set up"
