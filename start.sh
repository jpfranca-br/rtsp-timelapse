#!/bin/bash

# Get the configuration file from the argument, default to ./config.txt
CONFIG_FILE=${1:-./config.txt}
PID_FILE=/tmp/snapshot_capture.pid

# Function to read configuration values
read_config() {
  if [ -f "$CONFIG_FILE" ]; then
    RTSP=$(grep "^rtsp=" "$CONFIG_FILE" | cut -d'=' -f2)
    SNAPSHOT_PER_SECOND=$(grep "^snapshot_per_second=" "$CONFIG_FILE" | cut -d'=' -f2)
    SNAPS_DIR=$(grep "^snaps_dir=" "$CONFIG_FILE" | cut -d'=' -f2)
  else
    echo "Configuration file not found: $CONFIG_FILE"
    exit 1
  fi
}

# Read values from configuration file
read_config

# Expand tilde (~) in the snaps directory path
SNAPS_DIR=$(eval echo "$SNAPS_DIR")

# Ensure the directory exists
mkdir -p "$SNAPS_DIR"

# Check if a capture process is already running
if [ -f "$PID_FILE" ] && kill -0 "$(cat $PID_FILE)" 2>/dev/null; then
  echo "Snapshot capture is already running (PID: $(cat $PID_FILE))."
  exit 1
fi

# Start snapshot capture in the background, suppress output
echo "Starting snapshot capture"
echo "RTSP Feed : $RTSP"
echo "Frame rate: $SNAPSHOT_PER_SECOND frame(s) per second..."
ffmpeg -rtsp_transport tcp -err_detect ignore_err -max_delay 500000 \
-stimeout 5000000 -i "$RTSP" \
-an -vf fps=$SNAPSHOT_PER_SECOND -q:v 2 -pix_fmt yuvj422p "$SNAPS_DIR/snapshot_%04d.jpg" \
>/dev/null 2>&1 &

# Save the process ID
echo $! > "$PID_FILE"
echo "Snapshot capture started in the background (PID: $!)."

