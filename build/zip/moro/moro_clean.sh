#!/sbin/sh
#
# Clean app in packages.xml
# Remove apk in data/app, data/data, and system
#
# v3.0.5
# By morogoku 
# http://www.espdroids.com
#
#
# Usage:
#	moro_clean.sh [apk_package] -[options]
#
# Options:
#	a: remove apk in /data/app/apk_package
#	d: remove data of apk from /data/data/apk_package
#	s: remove apk if /system/app/apk or /system/priv-app/apk
# 
# example:
#	clean only in packages.xml:
#	    moro_clean.sh com.sec.android.app.music
#
#	clean in packages.xml and remove apk in data/app:
#	    moro_clean.sh com.sec.android.app.music -a
#
#	clean on packages.xml, remove in data/app, remove data, and remove in system
#	    moro_clean.sh com.sec.android.app.music -ads
#
#
# In a updater-script file, copy moro_clean.sh to tmp and:
#   run_program("/tmp/moro_clean.sh", "com.sec.android.app.music", "-ads");
#
#



# Busybox 
BB=/sbin/busybox;


run_script(){

	xfound=0

	while :
	do
		x=$($BB grep -n ''$ruta'' packages.xml -m 1 | $BB cut -d: -f 1);
		y=$((x + 1));

		if [[ ! -z $x ]]; then
			
			xfound=1
			
			a=$(echo $($BB awk 'NR=='$x'' packages.xml) | $BB awk '{print $3}' | $BB cut -c1-12)
			if [ "$a" == "codePath=\"/s" ]; then
				system_path=$(echo $($BB awk 'NR=='$x'' packages.xml) | $BB awk '{print $3}' | $BB cut -c 10- | $BB sed -e 's/^.//' -e 's/.$//')
			fi


			while :
			do
				z=$(echo $($BB awk 'NR=='$y'' packages.xml) | $BB cut -d " " -f 1)
				if [ "$z" == "</package>" ] || [ "$z" == "</updated-package>" ] || [ "$z" == "</shared-user>" ] || [ "$z" == "<updated-package" ]; then
					if [ "$z" == "<updated-package" ]; then
						let "y=y-1";
					fi
					break;
				fi

				let "y=y+1";
				done;

				mv packages.xml temp.xml
				$BB sed ''${x},${y}d'' temp.xml > packages.xml
				$BB echo "MC3[i]:  -- found and cleaned"
				rm -f temp.xml

				$BB chmod 0660 packages.xml;
				$BB chown 1000.1000 packages.xml;
		else
			if [[ $xfound = 0 ]]; then
				$BB echo "MC3[E]: Wrong package or not found"
			fi
			break;
		fi

	done;
}


# If packages.xml not exist, abort
if [ -f /data/system/packages.xml ]; then

	# Prepare packages.xml
	cd /data/system

	if [ -f packages-bak.xml ]; then
		rm -f packages-bak.xml
	fi

	# Backup packages.xml
	cp packages.xml packages-bak.xml
	

	# If package is entered run script
	if [[ ! -z $1 ]]; then

		ruta="name=\"$1\"";
		pkg=$1;
		$BB echo "MC3[i]: Searching $1 in packages.xml...";
		run_script;

		# If entered options
		if [[ ! -z $2 ]] && [[ $xfound = 1 ]]; then
		
			# If option "a" Remove apk from /data/app
			case $2 in *a*)				
				rm -rf /data/app/$pkg*
				$BB echo "MC3[i]: Option a -> Removing from /data/app ..."
			;; esac
			
			# If option "d" Remove apk data from /data/data
			case $2 in *d*)	
				rm -rf /data/data/$pkg;
				$BB echo "MC3[i]: Option d -> Removing from /data/data ...";
			;; esac
			
			# If option "s" Remove apk from system if exist
			case $2 in *s*)	
				if [ "$system_path" != "" ]; then
					rm -rf $system_path;
					$BB echo "MC3[i]: Option s -> Removing $system_path ...";
				else
					$BB echo "MC3[i]: Option s -> Not found apk in system";
				fi
			;; esac

		else
			if [[ $xfound = 1 ]]; then
				$BB echo "MC3[i]: No options entered";
			fi
		fi

	else
		$BB echo "MC3[E]: Missing package name"
	fi
	
else
	$BB echo "MC3[E]: /data wiped, packages.xml not exist, abort"
fi
