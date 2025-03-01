#!/bin/bash
source "$(dirname "$0")/.env"

# Function to make the API call and return only the access token
get_access_token() {
    local response
    response=$(curl --silent --request POST \
        --url "$UPTIMEKUMA_URL/login/access-token" \
        --header "Content-Type: application/x-www-form-urlencoded" \
        --data "username=$UPTIMEKUMA_USER" \
        --data "password=$UPTIMEKUMA_PASSWORD")

    # Extract the access_token using jq
    echo "$response" | jq -r '.access_token'
}

# Call the function and store the access token in a variable
access_token=$(get_access_token)


# Read urls.txt line by line
while read -r line; do
  name=$(echo "$line" | cut -d'.' -f1)  # Extract the first part of the domain as the app name
  name=$(echo "$name" | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}') # Capitalize first letter

  # Send request using name and line in the payload
  curl --request POST \
    --url "$UPTIMEKUMA_URL/monitors" \
    --header "Authorization: Bearer $access_token" \
    --header 'Content-Type: application/json' \
    --data "{
    \"type\": \"http\",
    \"name\": \"$name\",
    \"url\": \"https://$line\",
    \"accepted_statuscodes\": [
        \"200-299\"
    ],
    \"method\": \"GET\",
    \"dns_resolve_server\": \"192.168.1.13\"
    }"

  echo "Sent request for $name ($line)"
done < urls.txt
