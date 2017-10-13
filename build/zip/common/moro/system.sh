#!/sbin/sh
#
# MoRoKernel System script 1.0
#

cd /tmp/moro

# Extract system
tar -Jxf system.tar.xz

# Copy system
cp -rf system/. /system

# Patch fingerprint
rm -f /system/app/mcRegistry/ffffffffd0000000000000000000000a.tlbin

# Clean Apex data
rm -rf /data/data/com.sec.android.app.apex


