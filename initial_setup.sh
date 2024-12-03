#!/bin/bash

# Define user service directory
USER_OVERRIDE_DIR="$HOME/.config/systemd/user"
USER_SERVICE_FILE="$USER_OVERRIDE_DIR/timelapse.service"
LOGROTATE_FILE="/etc/logrotate.d/timelapse"

# Get the username of the person running this script and enable linger
CURRENT_USER=$(whoami)
sudo loginctl enable-linger $CURRENT_USER

# Verify lingering is enabled
if loginctl show-user $CURRENT_USER | grep -q "Linger=yes"; then
    echo "Lingering successfully enabled for $CURRENT_USER."
else
    echo "Failed to enable lingering for $CURRENT_USER."
fi

# Ensure the directory exists
mkdir -p "$USER_OVERRIDE_DIR"

# Define the current directory and ensure necessary files exist
CURRENT_DIR=$(pwd)
if [ ! -f "$CURRENT_DIR/capture.sh" ] || [ ! -f "$CURRENT_DIR/config.txt" ]; then
    echo "Required files (capture.sh and config.txt) not found in $CURRENT_DIR."
    exit 1
fi

# Create the user-level service file
echo "Creating user-specific service file"
cat > "$USER_SERVICE_FILE" <<EOF
[Unit]
Description=Timelapse Capture Service
After=network.target
StartLimitIntervalSec=0
#StopWhenUnneeded=true

[Service]
ExecStart=$CURRENT_DIR/capture.sh $CURRENT_DIR/config.txt
Restart=always
RestartSec=10
RemainAfterExit=false
WorkingDirectory=$CURRENT_DIR
Environment="CONFIG_FILE=$CURRENT_DIR/config.txt"
StandardOutput=journal
StandardError=journal

# Inherit environment for the user service
PassEnvironment=HOME USER LOGNAME PATH SHELL

[Install]
WantedBy=default.target
EOF

# Reload systemd user daemon to register the new service
echo "Reloading user systemd daemon"
systemctl --user daemon-reload

echo "Configuring logrotate for $CURRENT_DIR/capture.log"
sudo bash -c "cat > $LOGROTATE_FILE" <<EOF
$CURRENT_DIR/capture.log {
    size 1M
    rotate 5
    compress
    missingok
    notifempty
    copytruncate
}
EOF

# Print success message
echo "###"
echo "Timelapse user-specific service has been created."
echo "Control it with the following commands:"
echo "Start  : systemctl --user start timelapse.service"
echo "Stop   : systemctl --user stop timelapse.service"
echo "Enable : systemctl --user enable timelapse.service"
echo "Status : systemctl --user status timelapse.service"
echo "Logrotate configured for $CURRENT_DIR/capture.log with a max size of 1MB and 5 rotations."
