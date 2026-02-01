#!/bin/bash

if [ -d "$SERVER_ROOT" ]
then
  cat <<EOF | docker exec --interactive minecraft sh
  rcon-cli "playsound minecraft:block.note_block.bell block @a 0 0 0 1 0.5 1"
  sleep 0.25
  rcon-cli "playsound minecraft:block.note_block.bell block @a 0 0 0 1 0.5 1"
  sleep 0.125
  rcon-cli "playsound minecraft:block.note_block.bell block @a 0 0 0 1 0.749154 1"
  rcon-cli 'title @a times 10 100 10'
  rcon-cli 'title @a subtitle {"text":"Peak will reboot to update in 15 seconds.","color":"#BFFFFF"}'
  rcon-cli 'title @a title {"text":"Server rebooting"}'
EOF
  
  sleep 15

  cd "$SERVER_ROOT"
  docker compose down minecraft
  git fetch --all
  git reset --hard
else
  git clone "$REPOSITORY_URL" "$SERVER_ROOT"
  cd "$SERVER_ROOT"
fi

docker compose pull
docker image prune -f
docker compose up -d
