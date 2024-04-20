#!/bin/sh

alias upl="rsync -ciavuP --delete --exclude .git"

cd ~
git push

cd ~/dropbox
upl . du11:private_ftp

cd ~/dropbox/zk
git push
