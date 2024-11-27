### **RTSP TIMELAPSE**

---

## **Description**
This project includes two scripts, `start.sh` and `stop.sh`, along with a configuration file `config.txt`, designed to automate the process of capturing timelapses from an RTSP stream. It is particularly tailored for integration with **[OctoPrint](https://octoprint.org/)**, allowing the creation of a timelapse for each 3D print job automatically.

---

## **Files**

### **1. `start.sh`**
- **Purpose**: Captures frames from an RTSP stream at configurable intervals and stores snapshots in a specified directory.
- **How It Works**:
  - Reads configurations from `config.txt` (or another specified file).
  - Uses `ffmpeg` to continuously capture snapshots in the background.
  - Saves the running process ID (PID) in `/tmp/snapshot_capture.pid`.

### **2. `stop.sh`**
- **Purpose**: Stops the snapshot capture, creates a timelapse video from the snapshots, and removes the snapshots.
- **How It Works**:
  - Reads configurations from `config.txt` (or another specified file).
  - Stops the running snapshot process using the PID.
  - Uses `ffmpeg` to create a timelapse video in a specified directory.
  - Deletes the snapshots after the video is created.

### **3. `config.txt`**
- **Purpose**: Stores configuration values for the scripts.
- **Structure**:
  ```bash
  rtsp=rtsp://<user>:<password>@<ip>/live  # RTSP stream URL
  snapshot_per_second=0.1                  # Frame capture rate (frames per second)
  output_video_fps=6                       # Frame rate of the output video
  snaps_dir=~/snaps                        # Directory for storing snapshots
  video_dir=~/videos                       # Directory for saving the final video
  ```

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

## **How to Use**

### **1. Configure `config.txt`**
Edit `config.txt` to include:
- **RTSP stream URL (`rtsp`)**: The URL to your camera's RTSP stream.
- **Snapshot Rate (`snapshot_per_second`)**: How often snapshots should be captured (e.g., `1` for 1 frame per second).
- **Output Video FPS (`output_video_fps`)**: The playback speed of the resulting timelapse.
- **Directories**: Specify directories for snapshots (`snaps_dir`) and timelapse videos (`video_dir`).

Example:
```bash
rtsp=rtsp://user:pass@192.168.0.150/live
snapshot_per_second=1
output_video_fps=30
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

### **4. Integration with OctoPrint**
To automate timelapse creation for each 3D print, you can use the **Event Manager** in OctoPrint to trigger these scripts.

#### **Setup in OctoPrint**
1. Open **Settings** in OctoPrint.
2. Go to **Tools** > **Event Manager** > **Add Event**.
3. Add the following events:

**Event 1: Start Timelapse**
- **Name**: Start Timelapse  
- **Event(s)**: `PrintStarted`  
- **Command**:  
  ```bash
  ~/timelapse/start.sh ~/timelapse/config.txt
  ```
- **Type**: System  
- **Enabled**: Check  

**Event 2: Stop Timelapse**
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

## **Output Organization**

### **Snapshots**
- Saved in the directory specified in `snaps_dir` in `config.txt`.
- Example: `~/snaps`

### **Videos**
- Timelapse videos are saved in the directory specified in `video_dir` in `config.txt`.
- Example:
  ```bash
  ~/videos/output_video_<YYYY-MM-DD_HH-MM-SS>.mp4
  ```

---

## **Example Workflow**

1. **Configure `config.txt`**:
   ```bash
   rtsp=rtsp://user:pass@192.168.0.150/live
   snapshot_per_second=0.5
   output_video_fps=15
   snaps_dir=~/octoprint_snaps
   video_dir=~/octoprint_timelapses
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

## **Author and License**
This project is designed for capturing timelapses from RTSP streams and is optimized for OctoPrint integration. Use, modify, and distribute freely. 🚀
