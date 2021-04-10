#!/sbin/sh
#
# MoRoKernel Magisk Phh patch
#
#


unzip /tmp/moro/magisk/magisk.zip assets/boot_patch.sh -d /tmp/moro

line=$(grep -n './magiskboot cpio ramdisk.cpio \\' /tmp/moro/assets/boot_patch.sh | cut -d: -f 1);

sed -i ''${line}'a\
\"rm init.zygote32.rc\" \\\
\"rm init.zygote64_32.rc\" \
\
./magiskboot cpio ramdisk.cpio \\
' /tmp/moro/assets/boot_patch.sh

cd /tmp/moro
./zip -rv /tmp/moro/magisk/magisk.zip assets
rm -R common




