#!/bin/bash

NOW=$(date +"%Y%m%d_%H%M%S")
DIST="/tmp/nov_$NOW.tar.gz"
REMOTE="axcelott@december"

BASE_PATHS=(
    "/usr/local/bin/lift"
    "/usr/local/bin/lift-bootstrap"
    "/volume1/www/access.log"
    "/volume1/www/Caddyfile"
    "/volume1/www/ftp.dupunkto.org"
    "/volume1/www/cdn.geheimesite.nl"
    "/volume1/git"
    "/volume1/docker/.env"
    "/volume1/docker/postgres"
    "/volume1/docker/vik"
    "/volume1/docker/fog"
    "/volume1/gemini"
    "/volume1/gopher"
    "/volume1/homes/gitwastaken"
)

GLOB_PATHS=(
    "/volume1/www/*.sh"
    "/volume1/www/*.txt"
    "/volume1/www/*.tpl"
    "/volume1/www/dupunkto.org/~*"
    "/volume1/docker/fredericocraft*"
    "/volume1/docker/atlas*"
    "/volume1/docker/0bx*"
    "/volume1/docker/s11*"
)

for pattern in "${GLOB_PATHS[@]}"; do
    matches=( $pattern )
    if [ ${#matches[@]} -gt 0 ]; then
        BASE_PATHS+=( "${matches[@]}" )
    fi
done

echo "creating $DIST"
tar -czvf "$DIST" "${BASE_PATHS[@]}"
chmod 777 "$DIST"

echo "uploading $DIST to $REMOTE"
sudo -u axcelott rsync -avz "$DIST" "$REMOTE"

echo "deleting $DIST"
rm -f "$DIST"

echo "backup completed successfully!"
