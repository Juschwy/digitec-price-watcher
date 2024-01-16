#!/bin/bash

if [[ $(type -t logger) != function ]]; then
  logger (){
    echo "[LOG] $*"
  }
fi

logger script started

script_dir=$(dirname "$(readlink -f $0)")
script_dir=$(echo $script_dir)
logger "script_dir: $script_dir"

links=$(<"${script_dir}/links.txt")
ntfy_topic="<your-topic-name>"
ntfy_message=""

for link in $links; do
  link=$(echo $link)
  price=""
  counter=0
  while [[ -z "$price" && $counter -lt 10 ]]; do
    website=$(curl -s "$link")
    if [[ -z "$website" ]]; then
      website=$(curl "$link")
    fi
    price=$(echo "$website" | grep -o '<meta property="product:price:amount" content="[0-9]*\.[0-9]*"/>' | grep -o "[0-9]*\.[0-9]*")
  done;
  if [[ $counter -ge 10 ]]; then
    price="na"
  fi
  logger "$price"
  #name=$(echo "$website" | grep -o '<meta property="og:title" content=".*(.*).*"/>' | grep -o "\".*(.*).*\"")
  #echo $name

  ntfy_message+="\n${price} = ${link}"

done

ntfy_message=$(echo -e "$ntfy_message")
logger "ntfy_message: $ntfy_message"

if [[ -n "$ntfy_message" ]]; then
  curl \
    -H "Title: New Prices" \
    -d "$ntfy_message" \
    ntfy.sh/$ntfy_topic
else
  logger "no content sent"
fi

logger "script ended"