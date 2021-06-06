#!/sbin/sh
#
# MoRoKernel f2fs lineage 17/18 patch
#
#

FSTAB=${VENDOR}/etc/fstab.samsungexynos8890


if ! grep -q 'f2fs' ${FSTAB}; then 

line=$(grep -n 'USERDATA' ${FSTAB} | cut -d: -f 1);


sed -i ''${line}'a\
\/dev\/block\/platform\/155a0000.ufs\/by-name\/USERDATA         \/data       f2fs      noatime,nosuid,nodev,inline_xattr,data_flush,fsync_mode=nobarrier                               latemount,wait,check,encryptable=footer,quota \
\/dev\/block\/platform\/155a0000.ufs\/by-name\/CACHE            \/cache      f2fs      noatime,nosuid,nodev,inline_xattr,data_flush,fsync_mode=nobarrier                               wait,check
' ${FSTAB}

fi





