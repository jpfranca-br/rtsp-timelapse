#!/bin/bash

# Get the configuration file from the argument, default to ./config.txt
CONFIG_FILE=${1:-./config.txt}
PID_FILE=/tmp/snapshot_capture.pid

# Function to read configuration values
read_config() {
  if [ -f "$CONFIG_FILE" ]; then
    OUTPUT_VIDEO_FPS=$(grep "^output_video_fps=" "$CONFIG_FILE" | cut -d'=' -f2)
    SNAPS_DIR=$(grep "^snaps_dir=" "$CONFIG_FILE" | cut -d'=' -f2)
    VIDEO_DIR=$(grep "^video_dir=" "$CONFIG_FILE" | cut -d'=' -f2)
  else
    echo "Configuration file not found: $CONFIG_FILE"
    exit 1
  fi
}

# Read values from configuration file
read_config

# Expand tilde (~) in directory paths
SNAPS_DIR=$(eval echo "$SNAPS_DIR")
VIDEO_DIR=$(eval echo "$VIDEO_DIR")

# Ensure the video directory exists
mkdir -p "$VIDEO_DIR"

# Check if the snapshot capture is running
if [ ! -f "$PID_FILE" ] || ! kill -0 "$(cat $PID_FILE)" 2>/dev/null; then
  echo "No snapshot capture process is running."
  exit 1
fi

# Stop the snapshot capture process
echo "Stopping snapshot capture..."
kill "$(cat $PID_FILE)" && rm -f "$PID_FILE"
echo "Snapshot capture stopped."

# Generate a timestamp for the video
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
OUTPUT_VIDEO="$VIDEO_DIR/timelapse_${TIMESTAMP}.mp4"

# Combine snapshots into a video
echo "Combining snapshots into a video with frame rate: $OUTPUT_VIDEO_FPS fps..."
ffmpeg -framerate "$OUTPUT_VIDEO_FPS" -i "$SNAPS_DIR/snapshot_%04d.jpg" -c:v libx264 -pix_fmt yuv420p "$OUTPUT_VIDEO" >/dev/null 2>&1

if [ $? -eq 0 ]; then
  echo "Video created successfully at $OUTPUT_VIDEO"
else
  echo "Failed to create video."
  exit 1
fi

# Remove snapshot files
echo "Removing snapshot files..."
rm -f "$SNAPS_DIR"/*.jpg
if [ $? -eq 0 ]; then
  echo "All snapshots removed from $SNAPS_DIR."
else
  echo "Failed to remove snapshots."
fi
