#!/usr/bin/env bash


USERNAME="testuser"
PASSWORD="testing1"
MAIL="test@example.org"

curl -v -k -X PUT -H "Content-type: application/json" \
 -d '{"firstName":"${USERNAME}","lastName":"${USERNAME}","password":"${PASSWORD}","email":"${MAIL}","publicKeys":[]}' \
 "https://localhost:8443/ft1/api/v1/user/${USERNAME}"


curl -v -k -X POST -H "Accept: text/plain" -H "Content-type: text/plain" \
 -d '${PASSWORD}' \
 "https://localhost:8443/ft1/api/v1/user/${USERNAME}/certificate" --user ${USERNAME}:${PASSWORD}

