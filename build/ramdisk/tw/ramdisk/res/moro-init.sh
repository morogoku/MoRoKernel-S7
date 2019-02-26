#!/system/bin/sh
# 
# Init MoRoKernel 2
#

OLD_LOG="/data/morokernel.log"
MORO_DIR="/data/.morokernel"
LOG="$MORO_DIR/morokernel.log"

rm -f $LOG
rm -f $OLD_LOG

BB="/sbin/busybox"
RESETPROP="/res/magisk resetprop -v -n"


# Mount
$BB mount -t rootfs -o remount,rw rootfs;
$BB mount -o remount,rw /system;
$BB mount -o remount,rw /data;
$BB mount -o remount,rw /;

# Create morokernel folder
if [ ! -d $MORO_DIR ]; then
	mkdir -p $MORO_DIR;
fi


(
	echo $(date) "MoRo-Kernel LOG" >> $LOG
	echo " " >> $LOG

	
	# Stop secure_storage service
	su -c "stop secure_storage"


	# Selinux permissive
	echo "## -- Selinux permissive" >> $LOG
	echo "0" > /sys/fs/selinux/enforce 
	echo " " >> $LOG

	
	# SafetyNet
	echo "## -- SafetyNet permissions" >> $LOG
	chmod 640 /sys/fs/selinux/enforce
	chmod 440 /sys/fs/selinux/policy
	echo " " >> $LOG


	# Fake Knox 0
	echo "## -- Fake Knox 0" >> $LOG
	$RESETPROP ro.boot.warranty_bit "0"
	$RESETPROP ro.warranty_bit "0"
	echo " " >> $LOG

	
	# Samsung related flags
	echo "## -- Samsung Flags" >> $LOG
	$RESETPROP ro.fmp_config "1"
	$RESETPROP ro.boot.fmp_config "1"
	$RESETPROP ro.boot.verifiedbootstate "green"
	$RESETPROP ro.boot.veritymode "enforcing"
	$RESETPROP ro.boot.flash.locked "1"
	$RESETPROP ro.oem_unlock_supported "0"
	$RESETPROP sys.oem_unlock_allowed "0"
	$RESETPROP ro.debuggable "0"
	$RESETPROP ro.secure "1"
	#$RESETPROP ro.adb.secure "1"
	echo " " >> $LOG


	# deepsleep fix
	echo "## -- DeepSleep Fix" >> $LOG
	if [ -f /data/adb/su/su.d/000000deepsleep ]; then
		rm -f /data/adb/su/su.d/000000deepsleep
	fi
	
	for i in `ls /sys/class/scsi_disk/`; do
		cat /sys/class/scsi_disk/$i/write_protect 2>/dev/null | grep 1 >/dev/null
		if [ $? -eq 0 ]; then
			echo 'temporary none' > /sys/class/scsi_disk/$i/cache_type
		fi
	done
	echo " " >> $LOG

	# Google play services wakelock fix
	echo "## -- GooglePlay wakelock fix" >> $LOG
	su -c "pm enable com.google.android.gms/.update.SystemUpdateActivity"
	su -c "pm enable com.google.android.gms/.update.SystemUpdateService"
	su -c "pm enable com.google.android.gms/.update.SystemUpdateService$ActiveReceiver"
	su -c "pm enable com.google.android.gms/.update.SystemUpdateService$Receiver"
	su -c "pm enable com.google.android.gms/.update.SystemUpdateService$SecretCodeReceiver"
	echo " " >> $LOG

	
	# Fix personalist.xml
	if [ ! -f /data/system/users/0/personalist.xml ]; then
		touch /data/system/users/0/personalist.xml
		chmod 600 /data/system/users/0/personalist.xml
		chown system:system /data/system/users/0/personalist.xml
	fi

	
	# Suhide
	if [ -d /data/adb/su/suhide ]; then
		echo "## -- Start SUHide support" >> $LOG
		if [ -f /data/adb/su/su.d/zz99suhide ]; then
			rm -f /data/adb/su/su.d/zz99suhide
		fi

		sed -i '/supersu_prop/d' /plat_property_contexts
		restorecon /plat_property_contexts
		rm /init.supersu.rc
		rm -rf /boot

		/sbin/supersu/suhide/suhide
		echo " " >> $LOG
	fi
	
	
	# Init.d support
	echo "## -- Start Init.d support" >> $LOG
	if [ ! -d /system/etc/init.d ]; then
	    	mkdir -p /system/etc/init.d;
	fi

    	chown -R root.root /system/etc/init.d;
	chmod 777 /system/etc/init.d;

	if [ "$(ls -A /system/etc/init.d)" ]; then
		chmod 777 /system/etc/init.d/*;

		for FILE in /system/etc/init.d/*; do
			echo "## Executing init.d script: $FILE" >> $LOG
			sh $FILE >/dev/null;
	    	done;
	else
		echo "## No files found" >> $LOG
	fi
	echo "## -- End Init.d support" >> $LOG
	echo " " >> $LOG


	# Install APK
	echo "## -- Start Install APK" >> $LOG
	if [ ! -d $MORO_DIR/apk ]; then
		mkdir -p $MORO_DIR/apk;
		chown -R root.root $MORO_DIR/apk;
		chmod 750 $MORO_DIR/apk;
	fi

	if [ "$(ls -A /$MORO_DIR/apk)" ]; then
		cd $MORO_DIR/apk
		chmod 777 *;
		for apk in *.apk; do
			echo "## Install $apk" >> $LOG
			pm install -r $apk >/dev/null;
			rm $apk
		done;
	else
		echo "## No files found" >> $LOG
	fi
	echo "## -- End Install APK" >> $LOG


) 2>&1 | tee -a ./$LOG

chmod 777 $LOG

# Unmount
$BB mount -t rootfs -o remount,ro rootfs;
$BB mount -o remount,ro /system;
$BB mount -o remount,rw /data;
$BB mount -o remount,ro /;

