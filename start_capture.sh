#!/bin/bash
echo "Starting timelapse service."
export XDG_RUNTIME_DIR=/run/user/$(id -u)
systemctl --user start timelapse.service

