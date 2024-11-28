#!/bin/bash

# Get the configuration file from the argument, default to ./config.txt
CONFIG_FILE=${1:-./config.txt}
PID_FILE=/tmp/snapshot_capture.pid
STOP_FILE=/tmp/snapshot_capture_stop.flag

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

# Function to start ffmpeg and handle retries
start_ffmpeg() {
  while true; do
    echo "Starting snapshot capture..."
    echo "RTSP Feed : $RTSP"
    echo "Frame rate: $SNAPSHOT_PER_SECOND frame(s) per second..."

    # Start ffmpeg process
    ffmpeg -rtsp_transport tcp -err_detect ignore_err -max_delay 10000000 \
    -stimeout 10000000 -i "$RTSP" \
    -an -vf fps=$SNAPSHOT_PER_SECOND -q:v 2 -pix_fmt yuvj422p "$SNAPS_DIR/snapshot_$(date +%Y-%m-%d_%H-%M-%S)_%06d.jpg" \
    >/dev/null 2>&1 &

    # Save the process ID
    FF_PID=$!
    echo $FF_PID > "$PID_FILE"
    echo "Snapshot capture started with PID: $FF_PID."

    # Wait for the process to finish
    wait $FF_PID
    EXIT_STATUS=$?

    # Handle exit status
#    if [ $EXIT_STATUS -eq 0 ]; then
#      echo "ffmpeg exited gracefully (status: $EXIT_STATUS). Stopping restart loop."
#      break
    #el
    if [ -f "$STOP_FILE" ]; then
      echo "stop.sh executed. Stopping restart loop."
      rm -f $STOP_FILE
      break
    elif [ $EXIT_STATUS -eq 143 ]; then
      echo "ffmpeg terminated with SIGTERM (status: $EXIT_STATUS). Stopping restart loop."
      break
    elif [ $EXIT_STATUS -eq 130 ]; then
      echo "ffmpeg interrupted with SIGINT (Ctrl+C) (status: $EXIT_STATUS). Stopping restart loop."
      break
    else
      echo "ffmpeg exited with error (status: $EXIT_STATUS). Restarting..."
    fi
  done
}

# Check if a capture process is already running
if [ -f "$PID_FILE" ] && kill -0 "$(cat $PID_FILE)" 2>/dev/null; then
  echo "Snapshot capture is already running (PID: $(cat $PID_FILE))."
  exit 1
fi

# Start the ffmpeg process with retry mechanism
start_ffmpeg

