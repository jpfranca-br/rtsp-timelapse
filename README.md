# RTSP Timelapse for Octoprint Integration

## **Description**
This project automates the process of capturing timelapses from an RTSP stream using a robust service designed for reliability and integration with **[OctoPrint](https://octoprint.org/)**. It ensures consistent performance even in the event of feed interruptions and provides tools for seamless management and timelapse creation.

---

## **Key Features**
- **Service Auto-Restart**: Continuously captures snapshots, recovering automatically from FFmpeg errors.
- **User-Specific Control**: Implements user-level services for secure and straightforward operation.
- **Comprehensive Scripts**: Includes `manage.sh` for interactive control, individual scripts for manual tasks, and enhanced debugging.
- **OctoPrint Integration**: Automates timelapse capture for 3D printing workflows with customizable triggers.
- **Example Testing**: Supports test scenarios via `test_create_video.sh`.

---

## **Dependencies**

### **System Requirements**
- **FFmpeg**: Required for snapshots and video creation. **Git**: required for cloning this repository.
    ```bash
    sudo apt update -y && sudo apt install git ffmpeg -y
    ```  
---

## **Installation**

1. Clone the repository, make scripts executable, run the initial setup script
   ```bash
   cd ~ && rm -rf timelapse && git clone https://github.com/jpfranca-br/timelapse.git && cd timelapse && chmod +x *.sh && ./initial_setup.sh
   ```
2. Use `manage.sh` for service management:
   ```bash
   ./manage.sh
   ```

---

## **Configuration**

Edit `config.txt` to match your setup:
```bash
rtsp=rtsp://<username>:<password>@<camera-ip>/live
snapshot_per_second=0.1
output_video_fps=24
snaps_dir=~/timelapse/snapshots
video_dir=~/timelapse/videos
```

### **Advanced Configurations**
- Log rotation is configured to ensure logs don’t grow indefinitely (`capture.log` rotates at 1MB, keeping 5 backups).
- Service auto-restarts every 10 seconds after a failure, ensuring robustness.

---

## **Usage**

### **Interactive Management**
Use `manage.sh` to handle common tasks:
```bash
./manage.sh
```
Options include:
- Start/Stop Service
- View Logs
- Create Video
- Stop Service and Generate Timelapse

### **Manual Operations**
- Start Service:
  ```bash
  ./start_capture.sh
  ```
- Stop Service:
  ```bash
  systemctl --user stop timelapse.service
  ```
- Stop Service (if running) and Create Video:
  ```bash
  ./create_video.sh
  ```

### **Test Example**
Use `test_create_video.sh` for testing with snapshots in an `example/` subdirectory:
```bash
./test_create_video.sh
```

---

## **OctoPrint Integration**

### **Setup**
1. Open **Settings** in OctoPrint.
2. Add the following events in **Event Manager**:

#### **Start Timelapse**
- **Event(s)**: `PrintStarted`
- **Command**: `/path/to/timelapse/start_capture.sh`

#### **Stop Timelapse**
- **Event(s)**: `PrintDone`, `PrintCancelled`, `PrintFailed`
- **Command**: `/path/to/timelapse/create_video.sh /path/to/timelapse/config.txt`

### **Workflow**
- **Start**: Timelapse begins when a print starts.
- **Stop**: Timelapse stops and processes into a video upon print completion or failure.

---

## **Output Structure**
- **Snapshots**: Stored in the directory specified by `snaps_dir`.
- **Videos**: Saved in the directory specified by `video_dir`.

Example video filename:
```bash
timelapse_YYYY-MM-DD_HH-MM-SS.mp4
```

---

## **Troubleshooting**
1. Verify logs in `capture.log` for errors.
2. Use `journalctl --user -u timelapse.service` to inspect service logs.
3. Check if `config.txt` values are correctly set.
4. Ensure required directories exist and scripts have execute permissions.
