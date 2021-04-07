#!/sbin/sh
#
# MoRoKernel SAR init script
#
#


LOS18=0

# Scripts dir
SDIR=/data/.morokernel/scripts
mkdir -p $SDIR

# RC files dir
if [ -f /system_root/init.rc ]; then
  RCDIR=/system_root
else
  RCDIR=/system/etc/init/hw
  LOS18=1
fi


ui_print "-- Add init script for SAR roms"


# Clean init.rc
sed -i '/init.moro.rc/d' $RCDIR/init.rc
sed -i '/init.ts.rc/d' $RCDIR/init.rc
sed -i '/init.services.rc/d' $RCDIR/init.rc
sed -i '/init.spectrum.rc/d' $RCDIR/init.rc

# Copy kernel files
cp -f /tmp/moro/files/check_kernel.sh $SDIR
cp -f /tmp/moro/files/moro_init.sh $SDIR
cp -f /tmp/moro/files/fix_personalist.sh $SDIR
cp -f /tmp/moro/files/init_d.sh $SDIR
cp -f /tmp/moro/files/install_apk.sh $SDIR
cp -f /tmp/moro/files/tweaks.sh $SDIR
cp -f /tmp/moro/files/zram.sh $SDIR
cp -f /tmp/moro/files/init.spectrum.sh $SDIR
cp -f /tmp/moro/files/spa $SDIR
cp -f /tmp/moro/files/init.moro.rc $RCDIR
cp -f /tmp/moro/files/init.spectrum.rc $RCDIR
chmod 755 /data/.morokernel/*
chmod 755 $RCDIR/init.moro.rc
chmod 755 $RCDIR/init.spectrum.rc


line=$(grep -n 'import' $RCDIR/init.rc | cut -d: -f 1 | tail -n1);


# Add import init.moro.rc to init.rc, and init.spectrum.rc to init.moro.rc
if [ $LOS18 == 1 ]; then
  sed -i ''${line}'a\import \/system\/etc\/init\/hw\/init.moro.rc' $RCDIR/init.rc
  sed -i ''7'a\import \/system\/etc\/init\/hw\/init.spectrum.rc' $RCDIR/init.moro.rc
else
  sed -i ''${line}'a\import \/init.moro.rc' $RCDIR/init.rc
  sed -i ''7'a\import \/init.spectrum.rc' $RCDIR/init.moro.rc
fi

