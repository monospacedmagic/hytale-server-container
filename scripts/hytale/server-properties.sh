#!/bin/sh
set -eu

# Load dependencies
. "$SCRIPTS_PATH/utils.sh"

# Only run if the file exists
if [ -f "$PROPERTIES_FILE" ]; then
    log "Syncing server.properties" "$CYAN" "init"

    # We "build" our array of sed commands here
    # Each -e counts as one entry in the positional parameters
    set -- \
        -e "s/^server-ip=.*/server-ip=$SERVER_IP/" \
        -e "s/^server-port=.*/server-port=$SERVER_PORT/" \
        -e "s/^query.port=.*/query.port=$SERVER_PORT/" \
        -e "s/^rcon.port=.*/rcon.port=${RCON_PORT:-25575}/"

    # Pass the "array" ($@) directly into sed
    # We use a temporary file variable to ensure we don't lose data
    UPDATED_CONTENT=$(sed "$@" "$PROPERTIES_FILE")
    
    echo "$UPDATED_CONTENT" > "$PROPERTIES_FILE"
    
    log "[init]" "Configuration sync complete." "$GREEN"
else
    log "[init]" "server.properties not found. Skipping auto-config." "$YELLOW"
fi