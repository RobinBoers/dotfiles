#!/bin/bash

set -eou pipefail

NOW=$(date +"%Y%m%d_%H%M%S")
DIST="/tmp/nov_$NOW.tar.gz"
REMOTE="axcelott@100.86.248.63"

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
    "/volume1/docker/invidious"
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
)

for pattern in "${GLOB_PATHS[@]}"; do
    matches=( $pattern )
    if [ ${#matches[@]} -gt 0 ]; then
        BASE_PATHS+=( "${matches[@]}" )
    fi
done

echo "creating $DIST"
tar -czvf "$DIST" --ignore-failed-read "${BASE_PATHS[@]}" || {
    code=$?
    if [ "$code" -gt 1 ]; then
        exit "$code"
    fi
    echo "tar completed with warnings (some files missing)"
}
chmod 777 "$DIST" || true

echo "uploading $DIST to $REMOTE"
sudo -u axcelott rsync -avz "$DIST" "$REMOTE:"

echo "deleting $DIST"
rm -f "$DIST"

echo "backup completed successfully!"
