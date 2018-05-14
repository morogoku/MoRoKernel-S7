#!/sbin/sh
#
# MoRoKernel System script 1.0
#

cd /tmp/moro

# Extract gpu libs
tar -Jxf system.tar.xz system-r15

# Copy system
cp -rf system-r15/. /system



