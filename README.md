### RTSP Timelapse for Octoprint Integration

---

## **Description**
This project is designed to automate the process of capturing timelapses from an RTSP stream using a robust and auto-restarting service. It supports seamless integration with **[OctoPrint](https://octoprint.org/)** for 3D print jobs and offers enhanced reliability to recover from issues like feed interruptions.

---

## **Key Features**
- **Auto-Restart Capability**: Automatically restarts the service in case of FFmpeg errors, ensuring uninterrupted operation.
- **User-Level Service Management**: Offers user-specific control for easier management without requiring elevated permissions.
- **Flexible Interaction Options**: Includes a `manage.sh` menu for streamlined control, as well as individual scripts for manual operation.
- **OctoPrint Integration**: Automates timelapse creation during 3D print jobs.

---

## **Dependencies**

### **System Requirements**
- **FFmpeg**: Required for capturing snapshots and creating timelapse videos.
  - Install on Ubuntu/Debian:
    ```bash
    sudo apt update && sudo apt install ffmpeg
    ```
  - Install on CentOS/Fedora:
    ```bash
    sudo yum install ffmpeg  # CentOS
    sudo dnf install ffmpeg  # Fedora
    ```

---

## **How to Install**

1. Clone the repository:
   ```bash
   git clone https://github.com/jpfranca-br/timelapse.git
   cd timelapse
   ```

2. Make the scripts executable:
   ```bash
   chmod +x *.sh
   ```

3. Run the initial setup script to configure system and user services:
   ```bash
   ./initial_setup.sh
   ```

4. Try to start, stop, view service status
   ```bash
   ./manage.sh
   ```

---

## **How to Use**

### **1. Configure `config.txt`**
Ensure `config.txt` includes the correct settings for your RTSP feed, snapshot rate, and directories:
```bash
rtsp=rtsp://<username>:<password>@<camera-ip>/live
snapshot_per_second=.1
output_video_fps=6
snaps_dir=./snapshots
video_dir=./videos
```

### **2. Start and Stop Timelapse Capture**

#### **Option 1: Manual Service Control**
- Start:
  ```bash
  systemctl --user start timelapse.service
  ```
- Stop:
  ```bash
  systemctl --user stop timelapse.service
  ```

#### **Option 2: Script Shortcuts**
- Start: `./start_capture.sh`
- Stop and Create Video: `./create_video.sh`

#### **Option 3: Interactive Menu**
Use `manage.sh` for an interactive menu with options for starting/stopping services, viewing logs, and creating videos:
```bash
./manage.sh
```

### **3. Create Timelapse Video**
The `create_video.sh` script:
- Stops the capture service.
- Combines snapshots into a timelapse video.
- Cleans up snapshots after video creation.

---

## **Integration with OctoPrint**
This project can automate timelapse creation during 3D printing using OctoPrint's **Event Manager**. Follow these steps to set it up:

1. Open **Settings** in OctoPrint.
2. Navigate to **Event Manager** and add the following events:

### **Event 1: Start Timelapse**
- **Name**: Start Timelapse  
- **Event(s)**: `PrintStarted`  
- **Command**:  
  ```bash
  /path/to/timelapse/start_capture.sh /path/to/timelapse/config.txt
  ```
- **Type**: System  
- **Enabled**: Check  

### **Event 2: Stop Timelapse**
- **Name**: Stop Timelapse  
- **Event(s)**: `PrintDone`, `PrintCancelled`, `PrintFailed`  
- **Command**:  
  ```bash
  /path/to/timelapse/create_video.sh /path/to/timelapse/config.txt
  ```
- **Type**: System  
- **Enabled**: Check  

#### **How It Works**
- When a print starts, OctoPrint triggers the `start_capture.sh` script to begin capturing snapshots.
- When the print completes, is canceled, or fails, OctoPrint triggers the `create_video.sh` script to stop the snapshot process, create the timelapse video, and clean up.

---

## **Output Structure**
- **Snapshots**: Stored in `snaps_dir` as configured in `config.txt`.
- **Videos**: Saved in `video_dir` with a timestamp-based filename.

Example video path:
```bash
./videos/timelapse_YYYY-MM-DD_HH-MM-SS.mp4
```

---

## **Enhanced Reliability**
- The service is designed to auto-restart in case of interruptions, such as a lost RTSP feed.
- Systemd handles retries with a delay of 5 seconds between restarts.

---

## **Author and License**
This project is designed for creating reliable timelapses from RTSP streams, with a focus on user flexibility and OctoPrint integration. Use, modify, and distribute freely. 🚀

--- 

This version includes the OctoPrint instructions within the same document for user convenience.
