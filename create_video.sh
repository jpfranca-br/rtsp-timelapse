#!/bin/bash

# Get the configuration file from the argument, default to ./config.txt
CONFIG_FILE=${1:-./config.txt}
PID_FILE=/tmp/snapshot_capture.pid
STOP_FILE=/tmp/snapshot_capture_stop.flag

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
# Check if the timelapse.service is running
if systemctl --user is-active --quiet timelapse.service; then
  echo "timelapse.service is running. Stopping it..."
  # Stop the timelapse service
  systemctl --user stop timelapse.service
  if [ $? -eq 0 ]; then
    echo "timelapse.service stopped successfully."
  else
    echo "Failed to stop timelapse.service. Please check manually." >&2
    exit 1
  fi
else
  echo "timelapse.service is not running."
fi

# How many files in snap dir?
FILE_COUNT=$(find "$SNAPS_DIR" -type f | wc -l)

if [ "$FILE_COUNT" -gt 0 ]; then
  # Generate a timestamp for the video
  TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
  OUTPUT_VIDEO="$VIDEO_DIR/timelapse_${TIMESTAMP}.mp4"
  # Combine snapshots into a video
  echo "Combining $FILE_COUNT snapshots into a video with frame rate $OUTPUT_VIDEO_FPS fps..."
  TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
  echo "Started at $TIMESTAMP"
  ffmpeg -framerate "$OUTPUT_VIDEO_FPS" -pattern_type glob -i "$SNAPS_DIR/*.jpg" -c:v libx264 -preset ultrafast -pix_fmt yuv420p "$OUTPUT_VIDEO" >/dev/null 2>&1
  TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
  echo "Finished at $TIMESTAMP"
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
else
  echo "No images on snapshot folder"
fi

