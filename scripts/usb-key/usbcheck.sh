#!/bin/bash
USB_UUID="XXXX-XXXX"        # filesystem UUID of your USB stick (lsblk -f)

if lsblk -f | grep -q "$USB_UUID"; then
echo "USB key present"
exit 0
else
echo "USB key missing"
exit 1
fi
