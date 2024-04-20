#!/bin/sh

GREEN="$(tput setaf 2)"
GRAY="$(tput setaf 245)"
RESET="$(tput sgr0)"

upl="rsync -ciavuP --delete --exclude .git"

backup() {
  cd "$1"
  printf "\n${GRAY}==> $1${RESET}\n"
  shift 2
  $@
}

echo "Starting backup..."

backup ~             run git push
backup ~/dropbox     run $upl . du11:private_ftp
backup ~/dropbox/zk  run git push
backup ~/etc/aerc    run $upl accounts.conf du11

printf "\n${GREEN}Done!${RESET}\n"
