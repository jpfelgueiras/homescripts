#!/bin/bash
source "$(dirname "$0")/.env"

treafikAuth=$(echo -n "$TRAEFIK_API_USERNAME:$TRAEFIK_API_PASSWORD" | base64)

urls=$(curl -H "Authorization: Basic $treafikAuth" -s "$TRAEFIK_API_URL/api/http/routers" | jq -r '.[].rule' | grep '^Host(' | sed -E 's/^Host\(`(.*)`\)$/\1/')

# Remove duplicates and save to file
echo "$urls" | sort -u > urls.txt

# Print the output
cat urls.txt
