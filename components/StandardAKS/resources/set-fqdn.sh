#!/usr/bin/env bash

NODE_RESOURCE_GROUP="$1"

count=0
until az network public-ip list --resource-group ${NODE_RESOURCE_GROUP} --query "[?contains(name, 'kubernetes')].{id:id}" --output tsv 1> /dev/null 2> /dev/null; do
    if [[ ${count} -eq 24 ]]; then
        echo "Timed out waiting for public IP becomes accessible"
        exit 1
    else
        count=$((count + 1))
    fi

    echo "Wait until public IP becomes accessible"
    sleep 20
done

PUBLICIP_ID=$(az network public-ip list --resource-group ${NODE_RESOURCE_GROUP} --query "[?contains(name, 'kubernetes')].{id:id}" --output tsv)

echo ${PUBLICIP_ID}

