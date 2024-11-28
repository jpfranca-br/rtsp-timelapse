#!/bin/bash

# Log file for debugging
LOG_FILE=$(dirname "$0")/capture.log

# Start logging
exec > >(tee -a "$LOG_FILE") 2>&1

# Print environment for debugging
echo "Debug: Environment variables:"
env

# Get the configuration file from the argument, default to ./config.txt
CONFIG_FILE=${1:-./config.txt}

# Read configuration values
if [ -f "$CONFIG_FILE" ]; then
  RTSP=$(grep "^rtsp=" "$CONFIG_FILE" | cut -d'=' -f2)
  SNAPSHOT_PER_SECOND=$(grep "^snapshot_per_second=" "$CONFIG_FILE" | cut -d'=' -f2)
  SNAPS_DIR=$(grep "^snaps_dir=" "$CONFIG_FILE" | cut -d'=' -f2)
else
  echo "Configuration file not found: $CONFIG_FILE"
  exit 1
fi

# Expand tilde (~) in the snaps directory path
SNAPS_DIR=$(eval echo "$SNAPS_DIR")

# Ensure the directory exists
mkdir -p "$SNAPS_DIR"

# Start ffmpeg process
echo "Starting snapshot capture..."
echo "RTSP Feed : $RTSP"
echo "Frame rate: $SNAPSHOT_PER_SECOND frame(s) per second..."

ffmpeg -rtsp_transport tcp -err_detect ignore_err -max_delay 10000000 \
-stimeout 10000000 -i "$RTSP" \
-an -vf fps=$SNAPSHOT_PER_SECOND -q:v 2 -pix_fmt yuvj422p \
"$SNAPS_DIR/snapshot_$(date +%Y-%m-%d_%H-%M-%S)_%06d.jpg"
