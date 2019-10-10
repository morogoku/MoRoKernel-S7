#!/system/bin/sh

HW_REV=`getprop ro.boot.hw_rev`

setprop hw.revision $HW_REV
setprop ro.cbd.dt_revision 00$HW_REV
