#!/sbin/sh
# 
# Clean PersonalPageServices
# Cleaning in packages.xml script v1.0
# By morogoku 
# http://www.espdroids.com
#

BB=/sbin/busybox


# Clean PersonalPageServices
rm -rf /system/priv-app/PersonalPageService
rm -rf /data/data/com.samsung.android.personalpage.service
rm -f /data/system/users/privatemode*


# Cleaning packages.xml
cd /data/system

if [ -f packages-bak.xml ]; then
	rm -f packages-bak.xml
fi
	
cp /data/system/packages.xml /data/system/packages-bak.xml


ruta='codePath="/system/priv-app/PersonalPageService'

	# Script
	x=$($BB grep -n ''$ruta'' packages.xml | cut -d: -f 1);
	y=$((x + 1));
	if [[ ! -z $x ]]; then
		while :
		do
			z=$(echo $($BB awk 'NR=='$y'' packages.xml) | $BB cut -d " " -f 1)
			if [ "$z" == "</package>" ] || [ "$z" == "</updated-package>" ]; then
				break;
			fi

			let "y=y+1";
		done;
		
		mv packages.xml temp.xml
		$BB sed ''${x},${y}d'' temp.xml > packages.xml
		rm -f temp.xml

		$BB chmod 0660 packages.xml;
		$BB chown 1000.1000 packages.xml;
	fi



	

