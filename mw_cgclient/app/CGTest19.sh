#!/bin/bash

# Check if a file is provided as an argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <path-to-url-list-file>"
    exit 1
fi

url_list_file="$1"

if [ ! -f "$url_list_file" ]; then
    echo "File not found: $url_list_file"
    exit 1
fi

# Function to fetch a URL and print the status code
fetch_url() {
    url="$1"
    status_code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 10 --max-time 10 "$url")
    echo "URL: $url -> Status code: $status_code"
}

# Loop through the list of URLs indefinitely
while true; do
    while IFS= read -r url; do
        fetch_url "$url"
    done < "$url_list_file"
done
