#!/bin/bash
export XDG_RUNTIME_DIR=/run/user/$(id -u)

# Estimated speed to process videos
PROCESS_SPEED=4.8

# Example subfolder
EXAMPLE_DIR="example"

# Get the configuration file from the argument, default to ./config.txt
CONFIG_FILE=${1:-./config.txt}

# Function to read configuration values
read_config() {
  if [ -f "$CONFIG_FILE" ]; then
    OUTPUT_VIDEO_FPS=$(grep "^output_video_fps=" "$CONFIG_FILE" | cut -d'=' -f2)
    SNAPS_DIR=$(grep "^snaps_dir=" "$CONFIG_FILE" | cut -d'=' -f2)
    VIDEO_DIR=$(grep "^video_dir=" "$CONFIG_FILE" | cut -d'=' -f2)
  else
    echo "Configuration file not found: $CONFIG_FILE" >&2
    exit 1
  fi
}

# Read values from configuration file
read_config

# Validate configuration values
if [ -z "$OUTPUT_VIDEO_FPS" ] || [ -z "$SNAPS_DIR" ] || [ -z "$VIDEO_DIR" ]; then
  echo "Missing configuration values in $CONFIG_FILE" >&2
  exit 1
fi

# Expand tilde (~) in directory paths
SNAPS_DIR=$(eval echo "$SNAPS_DIR/$EXAMPLE_DIR")
VIDEO_DIR=$(eval echo "$VIDEO_DIR")
echo "$SNAPS_DIR"

# Ensure the video directory exists
mkdir -p "$VIDEO_DIR" || { echo "Failed to create video directory $VIDEO_DIR"; exit 1; }

# Stop timelapse.service if running
if systemctl --user is-active --quiet timelapse.service; then
  echo "Stopping timelapse.service..."
  systemctl --user stop timelapse.service || { echo "Failed to stop timelapse.service"; exit 1; }
fi

# Count .jpg files in SNAPS_DIR
FILE_COUNT=$(find "$SNAPS_DIR" -maxdepth 1 -type f -iname "*.jpg" | wc -l)

if [ "$FILE_COUNT" -gt 0 ]; then
  TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
  OUTPUT_VIDEO="$VIDEO_DIR/timelapse_${TIMESTAMP}.mp4"

  echo "Combining $FILE_COUNT snapshots into a video at $OUTPUT_VIDEO_FPS fps..."
  TIMESTAMP_START=$(date +"%Y-%m-%d %H:%M:%S")

  # Calculate the estimated time in seconds
  START_EPOCH=$(date -d "$TIMESTAMP_START" +"%s")
  ESTIMATED_SECONDS=$(awk "BEGIN {print int($FILE_COUNT / $PROCESS_SPEED)}")
  ESTIMATED_EPOCH=$((START_EPOCH + ESTIMATED_SECONDS))
  # Convert the estimated epoch time back to a human-readable timestamp
  TIMESTAMP_ESTIMATED=$(date -d "@$ESTIMATED_EPOCH" +"%Y-%m-%d %H:%M:%S")

  echo "FFMPEG   started: $TIMESTAMP_START"
  echo "FFMPEG estimated: $TIMESTAMP_ESTIMATED"

  ffmpeg -framerate "$OUTPUT_VIDEO_FPS" -pattern_type glob -i "$SNAPS_DIR/*.jpg" -c:v libx264 -preset ultrafast -pix_fmt yuv420p "$OUTPUT_VIDEO" >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    TIMESTAMP_END=$(date +"%Y-%m-%d %H:%M:%S")
    echo "FFMPEG completed: $TIMESTAMP_END"
    echo "Video saved to $OUTPUT_VIDEO"
  else
    echo "FFMPEG failed. Video not created." >&2
    exit 1
  fi
else
  echo "No images in $SNAPS_DIR. Video not created."
fi
