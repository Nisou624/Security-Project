#!/bin/bash

mkdir -p "Rayan"

msg="Nec possum tecum vivere, nec sine te"

SKEY=$(openssl rand -hex 16)
IV=$(openssl rand -hex 16)
HKEY=$(openssl rand -hex 16)

hmac=$(echo -n "$msg" | openssl dgst -sha256 -hmac "$HKEY" | awk '{print $2}')

CMSG=$(echo -n "$msg" | openssl enc -aes-256-cbc -K "${SKEY}" -iv "${IV}" -base64)

printf "Encrypted Message: $CMSG\nSecret Key: $SKEY\nHMAC: $HKEY\nIv: $IV" >> "Rayan/message.txt"

