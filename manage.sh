#!/bin/bash

# Function to display the menu and handle user input
show_menu() {
    echo -e "\nWhat would you like to do with the timelapse service?\n"
    echo "1. View Service Journal Log (Real-Time)"
    echo "2. View Service Status"
    echo "3. View Capture Script Log (Real-Time)"
    echo "4. Start Service"
    echo "5. Stop Service"
    echo "6. Stop Service and Create Video"
    echo "7. Exit"
    echo -n -e "\nEnter your choice [1-7]: "
}

# Menu loop

tput clear

while true; do
    show_menu
    read -r choice
    tput clear
    case $choice in
        1)
            echo "Displaying service journal log (real-time). Control+C to exit."
            journalctl --user -u timelapse.service -f
            ;;
        2)
            echo "Displaying timelapse service status."
            systemctl --user status timelapse.service
            ;;

        3)
            echo "Displaying capture script log. Control+C to exit."
            if [ -f capture.log ]; then
                tail -f capture.log
            else
                echo "Error: capture.log not found in the current directory."
            fi
            ;;
        4)
            echo "Starting timelapse service."
            systemctl --user start timelapse.service
            ;;
        5)
            echo "Stopping timelapse service."
            systemctl --user stop timelapse.service
            ;;
        6)
            echo "Stopping timelapse service and creating video."
            if [ -x "./create_video.sh" ]; then
                ./create_video.sh
                if [ $? -eq 0 ]; then
                    echo "Video creation completed successfully."
                else
                    echo "Video creation script failed." >&2
                    exit 1
                fi
            else
                echo "Error: create_video.sh is not executable or not found in the current directory." >&2
                exit 1
            fi
            ;;
        7)
            echo "Exiting the script. Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid choice. Please select a valid option [1-8]."
            ;;
    esac
done
