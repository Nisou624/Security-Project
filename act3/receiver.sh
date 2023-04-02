#!/bin/bash

mkdir -p "Sarah"

i=1
sp="/-\|"
while [ ! -f "Rayan/message.txt" ]
do
  printf "\b${sp:i++%${#sp}:1}"
done

file=$(cat "Rayan/message.txt")

Scle=$(echo "$file" | grep "Secret Key:" | awk '{print $3}')


crypted=$(echo "$file" | grep "Encrypted Message:" | awk '{print $3}')


Hmac=$(echo "$file" | grep "HMAC:" | awk '{print $2}')


inv=$(echo "$file" | grep "Iv:" | awk '{print $2}')


decrypted=$(echo -n "$crypted" | base64 -d | openssl enc -d -aes-256-cbc -K "$Scle" -iv "$inv")


chmac=$(echo -n "$decrypted" | openssl dgst -sha256 -hmac $Hmac | awk '{print $2}')


if [ "$HMAC" == "$CALCULATED_HMAC" ]; then
    echo "Message: $decrypted"
    echo "Message received, thank you " >> "Sarah/response.txt" 
else
    echo "You are not Sarah!"
fi

