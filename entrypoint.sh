#!/bin/sh
set -eu

# --- Configuration defaults ---
export SCRIPTS_PATH="/usr/local/bin/scripts"
export PROPERTIES_FILE="server.properties"
export SERVER_PORT="${SERVER_PORT:-5520}"
export SERVER_IP="${SERVER_IP:-0.0.0.0}"
export MINECRAFT="${MINECRAFT:-TRUE}"
export MINECRAFT_URL="${MINECRAFT_URL:-"https://piston-data.mojang.com/v1/objects/64bb6d763bed0a9f1d632ec347938594144943ed/server.jar"}"
export SERVER_JAR_PATH="/home/container/server.jar"
export DEBUG="${DEBUG:-FALSE}"
export PROD="${PROD:-FALSE}"

# Load utilities
. "$SCRIPTS_PATH/utils.sh"


sh "$SCRIPTS_PATH/hytale/binary_handler.sh"

# --- 1. Initialization ---
# These scripts use log_section internally
sh "$SCRIPTS_PATH/hytale/eula.sh"
sh "$SCRIPTS_PATH/hytale/server-properties.sh"


# --- 2. Audit Suite ---
log_section "Audit suite"
# Run Security and Network checks only if DEBUG is TRUE
if [ "${DEBUG:-FALSE}" = "TRUE" ]; then
    sh "$SCRIPTS_PATH/checks/security.sh"
    sh "$SCRIPTS_PATH/checks/network.sh"
else
    # Optional: A simple line to show audits are skipped
    echo -e "${DIM}System debug skipped (DEBUG=FALSE)${NC}"
fi

# Run Production readiness check only if PROD is TRUE
if [ "${PROD:-FALSE}" = "TRUE" ]; then
    sh "$SCRIPTS_PATH/checks/prod.sh"
else
    # Optional: A simple line to show audits are skipped
    echo -e "${DIM}Production audit skipped (PROD=FALSE)${NC}"
fi

# --- 4. Startup Command Parsing ---
log_section "Process Execution"
log_step "Parsing Startup Command"

# Default if Pterodactyl provides nothing
DEFAULT_STARTUP="java ${JAVA_OPTS:- -Xms128M -Xmx2048M} -jar $SERVER_JAR_PATH"
STARTUP_CMD="${STARTUP:-$DEFAULT_STARTUP}"

# Convert Pterodactyl's {{VARIABLE}} syntax to shell ${VARIABLE} and evaluate
MODIFIED_STARTUP=$(eval echo $(echo "$STARTUP_CMD" | sed -e 's/{{/${/g' -e 's/}}/}/g'))
log_success

# --- 5. Execution ---
echo -e "\n${BOLD}${CYAN}🚀 Launching Hytale/Minecraft Server...${NC}\n"
echo -e "${DIM}Command: $MODIFIED_STARTUP${NC}\n"

# Execute and replace the shell process
exec $MODIFIED_STARTUP