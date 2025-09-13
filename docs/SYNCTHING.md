# Syncthing: Secure File Synchronization with Encrypted Remote

Syncthing is a powerful, open-source tool for continuous file synchronization between devices. This guide will help you set up Syncthing with encrypted remote folders for maximum security.

---

## 1. Install Syncthing on All Devices

Follow the official instructions for your OS: [Syncthing Downloads](https://syncthing.net/downloads/)

---

## 2. Enable Syncthing Service on Startup (Linux)

```bash
sudo systemctl enable --now syncthing@$USER.service
```
This command enables and starts Syncthing as a user service, ensuring it runs automatically after reboot.

---

## 3. Access the Syncthing Web UI

By default, Syncthing's web interface runs on port **8384**.

For remote servers, use SSH tunneling. Run command on local machine:

```bash
ssh -L <local_port>:127.0.0.1:<server_port> user@server_ip
```
- Example: `ssh -L 8384:127.0.0.1:8384 user@server_ip`
- Then open [http://localhost:8384](http://localhost:8384) in your browser.

---

## 4. Initial Configuration

1. **Change Device Name:** Go to *Actions* → *Settings* → *General* → *Device Name* and set a unique name for each device.
2. **Set Minimum Free Disk Space:** Recommended: 5% (Settings → General → Minimum Free Disk Space).
3. **Secure the Web UI:**
    - Set a GUI username and password (Settings → GUI → Authentication).
    - Optionally, change the GUI port if needed.

---

## 5. Connect Devices

1. Click the **"+Add Remote Device"** button.
2. Enter the Device ID from another machine and a descriptive name.
3. For untrusted (encrypted) devices, go to *Advanced* tab and select **Untrusted Device**.

---

## 6. Add and Share Folders

1. Click **"+Add Folder"** and set a label and folder path.
2. To share a folder with a remote device:
    - Edit the remote device (Devices → Edit → Sharing tab).
    - Select the folders you want to share.
3. For untrusted devices, you have to add a folder password for encryption.

---

## Tips
- Always back up your data before enabling encryption.
- Review Syncthing's [official documentation](https://docs.syncthing.net/) for advanced options.
- Monitor device status and sync progress from the web UI.

---

Enjoy secure, private, and decentralized file synchronization with Syncthing!
