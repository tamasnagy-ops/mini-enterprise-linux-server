#!/bin/bash

USB_UUID="XXXX-XXXX"        # filesystem UUID of your USB stick (lsblk -f)
USB_ID="vvvv:pppp"          # USB vendor:product ID (lsusb)
SECRET_FILE="$HOME/linuxschool/secret.txt"
LOG_FILE="$HOME/linuxschool/access.log"
NOW=$(date)

if [ "$1" = "status" ]; then
echo "USB Secret Access Status"
echo "------------------------"

if lsusb | grep -q "$USB_ID"; then
echo "Hardware ID check: OK"
else
echo "Harware ID check: FAILED"
fi

if lsblk -f | grep -q "$USB_UUID"; then
echo "UUID check: OK"
else
echo "UUID check: FAILED"
fi

if [ -f "$SECRET_FILE" ]; then
echo "Secret file: OK"
else
echo "Secret file: MISSING"
fi
if [ -f "$LOG_FILE" ]; then
echo "Log file: OK"
else
echo "Log file: NOT CREATED YET"
fi
exit 0
fi

if ! lsusb | grep -q "$USB_ID"; then
echo "$NOW - Access denied - Hardware check failed" >> "$LOG_FILE"
echo "Access denied: USB hardware ID not found."
exit 1
fi

if ! lsblk -f | grep -q "$USB_UUID"; then
echo "$NOW - Access denied UUID check failed" >> "$LOG_FILE"
echo "Access denied: USB UUID not found."
exit 1
fi
if [ ! -f "$SECRET_FILE" ]; then
echo "$NOW - Access denied - Secret file missing" >> "$LOG_FILE"
echo "Access denied: secret file is missing."
exit 1
fi
echo "$NOW - Access allowed - UUID and USB hardware ID matched" >> "$LOG_FILE"
echo "Access allowed."
cat "$SECRET_FILE"
exit 0
