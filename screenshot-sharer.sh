#!/usr/bin/env bash

# Exit on error
set -e

# Logging configuration
LOG_FILE="$HOME/.local/share/screenshot-sharer/screenshot-sharer.log"
LOG_DIR=$(dirname "$LOG_FILE")

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Logging functions
log_info() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1" | tee -a "$LOG_FILE"
}

# Remote server configuration
REMOTE_USER="root"
REMOTE_HOST="admin.raizesespirituais.com.br"
REMOTE_PATH="/var/www/jeffrydegrande.com/s"  # Remote directory to store screenshots
PUBLIC_URL="https://jeffrydegrande.com/s"  # Public URL prefix

# Local configuration
LOCAL_SCREENSHOTS_DIR="$HOME/screenshots"  # Local directory to store screenshots

# Check dependencies
required_commands=("scrot" "satty" "rsync" "xclip" "notify-send")

for cmd in "${required_commands[@]}"; do
    if ! command -v $cmd >/dev/null 2>&1; then
        log_error "Required command '$cmd' not found"
        exit 1
    fi
done

log_info "All required commands found"

# Ensure local screenshots directory exists
mkdir -p "$LOCAL_SCREENSHOTS_DIR"
log_info "Using local screenshots directory: $LOCAL_SCREENSHOTS_DIR"

# Generate unique filename
timestamp=$(date +%Y%m%d-%H%M%S)
filename="screenshot-${timestamp}.png"
local_file="$LOCAL_SCREENSHOTS_DIR/$filename"

# Take screenshot and pipe to satty for annotation
log_info "Taking screenshot and opening in satty..."
if [ "$1" = "--select" ]; then
    log_info "Mode: Selection"
    scrot -s - | satty --fullscreen --filename - --output-filename "$local_file"
else
    log_info "Mode: Full screen (current monitor)"
    scrot - | satty --fullscreen --filename --output-filename "$local_file"
fi

# Upload to remote server
log_info "Uploading screenshot to remote server..."
rsync -avz "$local_file" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/"
log_info "Upload complete"

# Generate and copy URL to clipboard
url="$PUBLIC_URL/$filename"
echo -n "$url" | xclip -selection clipboard

notify-send "Screenshot Uploaded" "URL copied to clipboard: $url"
log_info "Screenshot URL copied to clipboard: $url"
