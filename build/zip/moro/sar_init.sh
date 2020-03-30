#!/sbin/sh
#
# MoRoKernel SAR init script
#
#


# Scripts dir
SDIR=/data/.morokernel/scripts
mkdir -p $SDIR


ui_print "-- Add init script for SAR roms"


# Clean init.rc
sed -i '/init.moro.rc/d' /system_root/init.rc
sed -i '/init.ts.rc/d' /system_root/init.rc
sed -i '/init.services.rc/d' /system_root/init.rc

# Copy kernel files
cp -f /tmp/moro/files/check_kernel.sh $SDIR
cp -f /tmp/moro/files/moro_init.sh $SDIR
cp -f /tmp/moro/files/fix_personalist.sh $SDIR
cp -f /tmp/moro/files/init_d.sh $SDIR
cp -f /tmp/moro/files/install_apk.sh $SDIR
cp -f /tmp/moro/files/tweaks.sh $SDIR
cp -f /tmp/moro/files/init.moro.rc /system_root
chmod 755 /data/.morokernel/*
chmod 755 /system_root/init.moro.rc


line=$(grep -n 'import' /system_root/init.rc | cut -d: -f 1 | tail -n1);


# Add import init.moro.rc to init.rc
sed -i ''${line}'a\import \/init.moro.rc' /system_root/init.rc

