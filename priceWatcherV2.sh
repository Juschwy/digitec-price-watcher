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
old_backup=$(<"${script_dir}/backups.yaml")
ntfy_topic="<your-topic-name>"
ntfy_message=""
new_backup=""

for link in $links; do
  link=$(echo $link)
  new_price=""
  counter=0
  while [[ -z "$new_price" && $counter -lt 10 ]]; do
    website=$(curl -s "$link")
    if [[ -z "$website" ]]; then
      website=$(curl "$link")
    fi
    new_price=$(echo "$website" | grep -o '<meta property="product:price:amount" content="[0-9]*\.[0-9]*"/>' | grep -o "[0-9]*\.[0-9]*")
  done;
  if [[ $counter -ge 10 ]]; then
    new_price="na"
  fi
  old_price=$(echo "$old_backup" | grep "${link}:[0-9]*\.[0-9]*" | cut -d":" -f3)
  if [[ "$old_price" != "" ]] && [[ "$old_price" != "$new_price" ]]; then
    ntfy_message+="\n${new_price} = ${link}"
  fi
  new_backup+="\n${link}:${new_price}"
  logger "${link}:${new_price}"
done

ntfy_message=$(echo -e "$ntfy_message")
logger "ntfy_message: '$ntfy_message'"

if [[ -n "$ntfy_message" && "$OS" != "Windows_NT" ]]; then
  curl \
    -H "Title: New Prices" \
    -d "$ntfy_message" \
    ntfy.sh/$ntfy_topic
else
  logger "no content sent"
fi

echo -e "$new_backup" > "$script_dir/backups.yaml"

logger "script ended"