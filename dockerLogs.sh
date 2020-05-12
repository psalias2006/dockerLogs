#!/bin/bash
DARKGRAY='\033[1;30m'
LIGHTRED='\033[1;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
LIGHTPURPLE='\033[1;35m'
CYAN='\033[0;36m'

COLORS=($DARKGRAY $LIGHTRED $GREEN $YELLOW $BLUE $LIGHTPURPLE $CYAN )
color_stop=$(printf '\033[0m')
size=${#COLORS[@]}


names=$(docker ps --format "{{.Names}}")
echo "tailing $names"

while read -r name
do
  index=$(($RANDOM % $size))
  color_start=$(printf ${COLORS[$index]})

  # eval to show container name in jobs list
  eval "docker logs -f --tail=5 \"$name\" | sed -e \"s/^/${color_start}[-- $name --]${color_stop} /\" &"
done <<< "$names"

function _exit {
  echo
  echo "Stopping tails $(jobs -p | tr '\n' ' ')"
  echo "..."

  # Using `sh -c` so that if some have exited, that error will
  # not prevent further tails from being killed.
  jobs -p | tr '\n' ' ' | xargs -I % sh -c "kill % || true"

  echo "Done"
}

# On ctrl+c, kill all tails started by this script.
trap _exit EXIT

# Don't exit this script until ctrl+c or all tails exit.
wait
