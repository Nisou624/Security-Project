#!/bin/bash

mkdir -p "act2"

stp=false
while [ "$stp" = false ]; do
	read -p "entrer les noms de comptes que vous voulez créer: " blaze
	echo $blaze >> "act2/names.txt"
	read -p "do you want to continue providing names? (Y/N)" yn
	case $yn in
		[yY] ) ;;
		[nN] ) stp=true;;
		* ) echo "réponse invalide";;
	esac
done

filename="names.txt"


IFS=$'\t\n '


names=()
while read -ra line; do
  for name in "${line[@]}"; do
    if [ -n "$name" ]; then
      names+=("$name")
    fi
  done
done < "act2/$filename"


unset IFS


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi


echo "Names in file $filename:"
for name in "${names[@]}"; do

	username="$name"
	password="$name"

	useradd -m -s /bin/bash $name
	echo "$name:$name" | chpasswd
	echo "User account created successfully"
	mkdir -p "/home/$name/KEYS"
	openssl genrsa -out "/home/$name/KEYS/pkey" 4096
	openssl rsa -in "/home/$name/KEYS/pkey" -pubout -out "/home/$name/KEYS/pubkey"
	openssl rsa -in "/home/$name/KEYS/pkey" -pubout -out "act2/'$name'.pubkey"
	chmod 700 "/home/$username/KEYS"
	chmod 600 "/home/$username/KEYS/pkey"
	chmod 644 "/home/$username/KEYS/pubkey"
	chmod 644 "act2/'$name'.pubkey"
done
