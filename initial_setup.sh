#!/bin/bash

# Get the current working directory
CURRENT_DIR=$(pwd)

# Get the username of the person running this script
CURRENT_USER=$(whoami)

# Define the service file path
SERVICE_FILE="/etc/systemd/system/timelapse.service"
USER_OVERRIDE_DIR="$HOME/.config/systemd/user"
USER_SERVICE_FILE="$USER_OVERRIDE_DIR/timelapse.service"
LOGROTATE_FILE="/etc/logrotate.d/timelapse"

# Create the system-wide service file
echo "Creating system-wide service file"
sudo bash -c "cat > $SERVICE_FILE" <<EOF
[Unit]
Description=Timelapse Capture Service
After=network.target

[Service]
ExecStart=$CURRENT_DIR/capture.sh $CURRENT_DIR/config.txt
Restart=always
RestartSec=5
User=$CURRENT_USER
WorkingDirectory=$CURRENT_DIR
Environment="CONFIG_FILE=$CURRENT_DIR/config.txt"

# Inherit environment for the user service
PassEnvironment=HOME USER LOGNAME PATH SHELL

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd to register the new system-wide service
echo "Reloading daemon"
sudo systemctl daemon-reload

# Configure a user-level service file for no-sudo start/stop
echo "Creating user-specific service file"
mkdir -p "$USER_OVERRIDE_DIR"
cat > "$USER_SERVICE_FILE" <<EOF
[Unit]
Description=Timelapse Capture Service
After=network.target

[Service]
ExecStart=$CURRENT_DIR/capture.sh $CURRENT_DIR/config.txt
Restart=always
RestartSec=5
WorkingDirectory=$CURRENT_DIR
Environment="CONFIG_FILE=$CURRENT_DIR/config.txt"

# No sudo needed because it's user-specific
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=default.target
EOF

# Reload systemd user daemon to register the new service
echo "Realoading damon again"
systemctl --user daemon-reload

# Configure logrotate for the capture.log file
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
echo "Timelapse service has been created. It is not enabled and not started. Control it yourself."
echo "System-wide service  : sudo  systemctl  start timelapse.service"
echo "User-specific service: systemctl --user start timelapse.service"
echo "Logrotate configured for $CURRENT_DIR/capture.log with a max size of 1MB and 5 rotations."
