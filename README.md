### **RTSP TIMELAPSE**

---

## **Description**
This project includes two scripts, `start.sh` and `stop.sh`, along with a configuration file `config.txt`, designed to automate the process of capturing timelapses from an RTSP stream. It is particularly tailored for integration with **[OctoPrint](https://octoprint.org/)**, allowing the creation of a timelapse for each 3D print job automatically.

---

## **Dependencies**

### **1. System Dependencies**
- **FFmpeg**: Used to capture frames and create the timelapse video.
  - Installation on Ubuntu/Debian:
    ```bash
    sudo apt update && sudo apt install ffmpeg
    ```
  - Installation on CentOS/Fedora:
    ```bash
    sudo yum install ffmpeg    # CentOS
    sudo dnf install ffmpeg    # Fedora
    ```

### **2. OctoPrint (Optional)**
- Designed for integration with OctoPrint to automate timelapse creation for 3D prints.
- Requires the Event Manager plugin (built-in in OctoPrint).

---

## **How to Install**
1. Clone or download the repository:
   ```bash
   git clone https://github.com/jpfranca-br/timelapse.git
   cd timelapse
   ```

2. Make the scripts executable:
   ```bash
   chmod +x start.sh stop.sh
   ```

3. Ensure `config.txt` is properly configured before running the scripts.

---

## **How to Use**

### **1. Configure `config.txt`**
Edit `config.txt` to include:
- **RTSP stream URL (`rtsp`)**: The URL to your camera's RTSP stream.
- **Snapshot Rate (`snapshot_per_second`)**: How often snapshots should be captured (e.g., `1` for 1 frame per second).
- **Output Video FPS (`output_video_fps`)**: The playback speed of the resulting timelapse.
- **Directories**: Specify directories for snapshots (`snaps_dir`) and timelapse videos (`video_dir`).

Example:
```bash
rtsp=rtsp://rtspstream:43c4a407fe60eaafa67c48b24d29c496@zephyr.rtsp.stream/pattern
snapshot_per_second=1
output_video_fps=6
snaps_dir=~/snaps
video_dir=~/videos
```

---

### **2. Start Snapshot Capture**
Run `start.sh` to start capturing snapshots:
```bash
./start.sh [config_file]
```
- If no `config_file` is specified, it defaults to `./config.txt`.
- Example:
  ```bash
  ./start.sh ~/timelapse/config.txt
  ```

---

### **3. Stop Snapshot Capture and Create Timelapse**
Run `stop.sh` to stop capturing snapshots, create a timelapse video, and clean up snapshots:
```bash
./stop.sh [config_file]
```
- If no `config_file` is specified, it defaults to `./config.txt`.
- Example:
  ```bash
  ./stop.sh ~/timelapse/config.txt
  ```

---

## **Output Organization**

### **Snapshots**
- Saved in the directory specified in `snaps_dir` in `config.txt`.
- Example: `~/snaps`
- Smapshots deleted after timelapse video is created

### **Videos**
- Timelapse videos are saved in the directory specified in `video_dir` in `config.txt`.
- Example:
  ```bash
  ~/videos/timelapse_<YYYY-MM-DD_HH-MM-SS>.mp4
  ```

---

## **Example Workflow**

1. **Configure `config.txt`**:
   ```bash
   rtsp=rtsp://rtspstream:43c4a407fe60eaafa67c48b24d29c496@zephyr.rtsp.stream/pattern
   snapshot_per_second=1
   output_video_fps=6
   snaps_dir=~/snaps
   video_dir=~/videos
   ```

2. **Start Capturing**:
   ```bash
   ./start.sh
   ```

3. **Stop Capturing and Create Video**:
   ```bash
   ./stop.sh
   ```

4. **Integration with OctoPrint**:
   - Automates the entire process during print jobs.

---

## **Integration with OctoPrint**
To automate timelapse creation for each 3D print, you can use the **Event Manager** in OctoPrint to trigger these scripts.

### **Setup in OctoPrint**
1. Open **Settings** in OctoPrint.
2. [Go to **Event Manager** > **Add Event**](https://github.com/jpfranca-br/timelapse/blob/main/img/01%20-%20octoprint-event_manager.png).
3. Add the following events:

[**Event 1: Start Timelapse**](https://github.com/jpfranca-br/timelapse/blob/main/img/02%20-%20octoprint-start_timelapse.png)
- **Name**: Start Timelapse  
- **Event(s)**: `PrintStarted`  
- **Command**:  
  ```bash
  ~/timelapse/start.sh ~/timelapse/config.txt
  ```
- **Type**: System  
- **Enabled**: Check  

[**Event 2: Stop Timelapse**](https://github.com/jpfranca-br/timelapse/blob/main/img/03%20-%20octoprint-stop_timelapse.png)
- **Name**: Stop Timelapse  
- **Event(s)**: `PrintCancelled`, `PrintDone`, `PrintFailed`  
- **Command**:  
  ```bash
  ~/timelapse/stop.sh ~/timelapse/config.txt
  ```
- **Type**: System  
- **Enabled**: Check  

#### **How It Works in OctoPrint**
- When a print starts, OctoPrint triggers the `start.sh` script to begin capturing snapshots.
- When the print completes, is canceled, or fails, OctoPrint triggers the `stop.sh` script to stop the snapshot process, create the timelapse video, and clean up.

---

## **Author and License**
This project is designed for capturing timelapses from RTSP streams and is optimized for OctoPrint integration. Use, modify, and distribute freely. 🚀
