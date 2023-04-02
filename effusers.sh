#!/bin/bash

filename="names.txt"
names=()
while read -ra line; do
  for name in "${line[@]}"; do
    if [ -n "$name" ]; then
      names+=("$name")
    fi
  done
done < "act2/$filename"

for name in "${names[@]}"; do 
	sudo userdel -r $name
done
