#!/bin/zsh
# run rclone as a daemon to silently mount drives without launching terminal on login
rclone mount --daemon remotename:path localpath