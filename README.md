# **Rclone setup**

- [**Rclone setup**](#rclone-setup)
  - [**Setup on Mac**](#setup-on-mac)
    - [**Install OSXFuse**](#install-osxfuse)
    - [**Install Rclone**](#install-rclone)
    - [**Optional: Get private credentials**](#optional-get-private-credentials)
    - [**Configure remote**](#configure-remote)
    - [**Mount remote manually**](#mount-remote-manually)
    - [**Mount remote on boot**](#mount-remote-on-boot)
    - [**How to unmount remotes**](#how-to-unmount-remotes)

## **Setup on Mac**

### **Install OSXFuse**

Get OSXFuse at [osxfuse.github.io](https://osxfuse.github.io/)

### **Install Rclone**

Check latest install instructions at [rclone.org](https://rclone.org/downloads/)

```bash
curl https://rclone.org/install.sh | sudo bash
```

### **Optional: Get private credentials**

You can use your own credentials if you don't want to be rate limited. These credentials need to be stored locally for rclone to read. Otherwise you will use the shared credentials at the official rclone project.

For Google drive, follow [this guide](https://rclone.org/drive/#service-account-support)
For Microsoft onedrive, follow [this guide](https://rclone.org/onedrive/#getting-your-own-client-id-and-key)

### **Configure remote**

We use the same command to create a new remote, edit existing remotes and remove them.

```bash
rclone config
```

### **Mount remote manually**

Mounting a drive is quite straightforward. Please read up on the flags.

```bash
rclone mount remote:path /path/to/mountpoint [flags]
# example: mount local folder gdrive to remote private_drive
# rclone mount private_gdrive:/ gdrive
```
### **Mount remote on boot**

I couldn't make cron load this on boot on a Mac, but launchd works. Here's how to set it up to launch silently on user login.

I chose to make a shell script also so I can easily add and remove drives.

Create a `plist` file for the launchd job, then add it with `launchctl`. 

I chose to make this a Launch Agent for the *specific logged in user* instead of a system task because the files and remote drive probably belong to a specific person and not all users on the same machine. 

Here's an example shell script to silently mount a drive as a daemon:

```bash
#!/bin/zsh
# run rclone as a daemon to silently mount drives without launching terminal on login
rclone mount --daemon remotename:path localpath
```
Here's a template for launching a shell script with launchd on login:

```xml
<?xml version="1.0" encoding="UTF-8"?>
	<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN"
		"http://www.apple.com/DTDs/PropertyList-1.0.dtd">
	<plist version="1.0">
	<dict>
		<key>EnvironmentVariables</key>
		<dict>
			<key>PATH</key>
			<string>addpath</string>
		</dict>
		<key>Label</key>
		<string>com.mountrclone</string>
		<key>Program</key>
		<string>pathtoshellscript.sh</string>
		<key>RunAtLoad</key>
		<true/>
		<key>StandardOutPath</key>
		<string>pathto/rclonesetup/out.log</string>
		<key>StandardErrorPath</key>
		<string>pathto/error.log</string>
	</dict>
	</plist>
```

These files should follow a naming convention to be the same name as the task. Look at existing tasks for some examples. Here are some of mine:

```
com.cisco.proximity.plist
```

Add this file to your user's library path, which should look like this `/Users/username/Library/LaunchAgents`

If you want to make this a system task then you need to use the System folder instead.

Then add the job:

```bash
# permanently load job for logged in user launch agents
launchctl load -w ~/Library/LaunchAgents/com.mountrclone.plist
# permanently unload job 
launchctl unload -w ~/Library/LaunchAgents/com.mountrclone.plist
```

If there's a problem with the job then there should be an error command when attempting to load it.

Try to reboot, login and check if the drive was mounted.

### **How to unmount remotes**

Use OSXFuse to unmount drives. 

```bash
umount drivename
# example: unmount drive called gdrive
#  umount gdrive
```

