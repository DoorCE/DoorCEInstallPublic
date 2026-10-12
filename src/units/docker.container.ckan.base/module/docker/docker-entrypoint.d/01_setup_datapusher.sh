# #!/bin/bash

# if [[ $CKAN__PLUGINS == *"datapusher"* ]]; then
#    # Datapusher settings have been configured in the .env file
#    # Set API token if necessary
#    if [ -z "$CKAN__DATAPUSHER__API_TOKEN" ] ; then
#       echo "Set up ckan.datapusher.api_token in the CKAN config file"
#       TOKEN=$(ckan -c $CKAN_INI user token add ckan_admin datapusher | tail -n 1 | tr -d '\t')
#       ckan config-tool $CKAN_INI "ckan.datapusher.api_token=$TOKEN"
#       install -m 600 /dev/null /tmp/datapusher_api_token.txt && echo "$TOKEN" > /tmp/datapusher_api_token.txt
#    fi
# else
#    echo "Not configuring DataPusher"
# fi