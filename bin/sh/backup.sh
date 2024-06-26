#!/bin/sh

GREEN="$(tput setaf 2)"
GRAY="$(tput setaf 245)"
RESET="$(tput sgr0)"

rcp="rsync -ciavuP --delete --exclude .git"

backup() {
  cd "$1"
  printf "\n${GRAY}==> $1${RESET}\n"
  shift 2
  $@
}

echo "Starting backup..."

backup ~             run git push
backup ~/dropbox     run $rcp . du11:private_ftp
backup ~/dropbox/zk  run git push
backup ~/etc/aerc    run $rcp accounts.conf du11:accounts.conf

printf "\n${GREEN}Done!${RESET}\n"
