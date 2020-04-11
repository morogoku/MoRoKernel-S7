#!/system/bin/sh
# 
# Check MoRoKernel
# by morogoku
#

mount -t rootfs -o rw,remount rootfs;
#mount -o rw,remount /system;
mount -o rw,remount /data;
mount -o rw,remount /;


# Clean init.rc
sed -i '/init.ts.rc/d' /init.rc
sed -i '/init.services.rc/d' /init.rc


# If no MoroKernel v8 installed, remove files 
if ! grep -q MoRoKernel /proc/version && ! grep -q v8 /proc/version; then 
    rm -f /init.moro.rc
    sed -i '/init.moro.rc/d' /init.rc
    rm -Rf /data/.morokernel
fi


#Unmount
mount -t rootfs -o ro,remount rootfs;
#mount -o ro,remount /system;
mount -o rw,remount /data;
mount -o ro,remount /;
