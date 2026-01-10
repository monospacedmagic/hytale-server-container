#!/bin/sh
set -eu

# Load dependencies
. "$SCRIPTS_PATH/utils.sh"

# We assume MINECRAFT is the toggle (TRUE/FALSE)
# and MINECRAFT_URL contains the actual download link.
if [ "${MINECRAFT:-FALSE}" = "TRUE" ]; then    
    log_section "Minecraft Fallback Mode"
    
    log_step "Searching for server JAR"
    # Look for any existing jar that looks like a server
    FOUND_JAR=$(ls /home/container/*.jar 2>/dev/null | grep -iE "server|minecraft|spigot|paper" | head -n 1 || echo "")

    if [ -z "$FOUND_JAR" ]; then
        log_warning "No JAR found." "Preparing to download from external source."
        
        # Ensure the URL variable isn't empty
        if [ -z "${MINECRAFT_URL}" ]; then
            log_error "Download failed." "MINECRAFT_URL is not defined in environment variables."
            exit 1
        fi

        log_step "Downloading Minecraft Server"
        # Using the variable instead of the hardcoded Mojang link
        if curl -sSL -o "$SERVER_JAR_PATH" "$MINECRAFT_URL"; then
            log_success
            
            log_step "Securing binary (Read-Only)"
            if chmod 444 "$SERVER_JAR_PATH"; then
                log_success
            else
                log_warning "Permissions check" "Could not set 444, but file was downloaded."
            fi
        else
            log_error "Download failed." "Check network connectivity or the URL: ${MINECRAFT_URL}"
            exit 1
        fi
    else
        log_success
        echo -e "      ${DIM}↳ Found:${NC} ${GREEN}$(basename "$FOUND_JAR")${NC}"
        SERVER_JAR_PATH="$FOUND_JAR"
    fi
fi