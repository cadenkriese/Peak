#!/bin/bash

set -euo pipefail # Fail this script if git docker or other commands fail

if [ -d "$SERVER_ROOT" ]
then
  cat <<EOF | docker exec --interactive minecraft sh
  rcon-cli "playsound minecraft:block.note_block.bell block @a 0 0 0 1 0.5 1"
  sleep 0.25
  rcon-cli "playsound minecraft:block.note_block.bell block @a 0 0 0 1 0.5 1"
  sleep 0.125
  rcon-cli "playsound minecraft:block.note_block.bell block @a 0 0 0 1 0.749154 1"
  rcon-cli 'title @a times 10 100 10'
  rcon-cli 'title @a subtitle {"text":"Peak will reboot in 15 seconds.","color":"#BFFFFF"}'
  rcon-cli 'title @a title {"text":"World resetting"}'
EOF
  
  sleep 15

  cd "$SERVER_ROOT"
  docker compose down
  git fetch --all
  git reset --hard
  
  WORLD_DIR="$SERVER_ROOT/data/world"
  [[ -d "$WORLD_DIR" ]] || { echo "World directory missing"; exit 1; }
  
  max=0
  for f in "$BACKUP_DIR"/run_*.tar.gz; do
    [[ -e $f ]] || continue
    n=${f##*run_}
    n=${n%.tar.gz}
    (( n > max )) && max=$n
  done
  NEXT_RUN=$((max + 1))
  
  tar -cvf "$SERVER_ROOT/backups/run_${NEXT_RUN}.tar.gz" "$SERVER_ROOT/data/world"
  rm -r -- "$SERVER_ROOT/data/world"
  
  docker compose pull
  docker image prune -f
  docker compose up -d
  
else
  echo "Invalid SERVER_ROOT"
  exit 1
fi
