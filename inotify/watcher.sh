#!/bin/bash

# Watch this directory recursively (see -r below)
WATCH_DIR="/var/www/html/uploads"
LOG_FILE="/var/log/clamav-upload-scan.log"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $1" >> "$LOG_FILE"
}

# we can also use --exclude='\.ext$' to exclude files with ext extension (case sensitive)
# use --excludei for insensitive case (BETTER OPTION)
inotifywait -m -r -e close_write -e moved_to --format '%w%f' "$WATCH_DIR" | while read FILE
do
    log "VIRUS FOUND: $FILE"
    # automatically remove the file if virus found
    SCAN_OUTPUT=$(/usr/bin/clamdscan --no-summary --remove "$FILE" 2>&1)
    SCAN_EXIT=$?

    if [ $SCAN_EXIT -eq 0 ]; then
        log "OK: $FILE"
    elif [ $SCAN_EXIT -eq 1 ]; then
        log "DETAILS: $SCAN_OUTPUT"

        # Quarantine the file (not actually needed)
        # mv "$FILE" /var/quarantine/
    else
        log "ERROR scanning $FILE"
        log "DETAILS: $SCAN_OUTPUT"
    fi
done
