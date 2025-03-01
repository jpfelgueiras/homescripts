#!/bin/bash
source "$(dirname "$0")/.env"

cat urls.txt | while read line; do
  name=$(echo "$line" | cut -d'.' -f1)  # Extract the first part of the domain as the app name
  name=$(echo "$name" | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}') # Capitalize first letter
  json_payload=$(jq -n --arg name "$name" --arg url "$line" \
    '{name: $name, url: $url, icon: "application", isPublic: true, description: ""}')
  
  curl -X POST "$FLAME_URL/api/apps" \
       -H "Content-Type: application/json" \
       -H "Authorization-Flame: Bearer $FLAME_TOKEN" \
       -d "$json_payload"

  echo "Sent request for $line"
done
