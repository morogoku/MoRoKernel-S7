#!/sbin/sh
#
# Clean app in packages.xml script v1.3
# By morogoku 
# http://www.esp-desarrolladores.com
#

# Definimos busybox
BB=/system/xbin/busybox

cp /data/system/packages.xml /data/system/packages-bak.xml

run_script(){

	cd /data/system

	if [ -f packages-bak.xml ]; then
		rm -f packages-bak.xml
	fi


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
}

# Comprobamos si se ha metido la ruta
if [[ ! -z $1 ]]; then
	
	# Cargamos la ruta
	case $1 in
	  magisk)
		ruta='codePath="/data/app/com.topjohnwu.magisk'
		run_script;
		ruta='codePath="/system/priv-app/Magisk'
		run_script;
		ruta='codePath="/system/app/Magisk'
		run_script;
	  ;;
	  supersu)
		ruta='codePath="/data/app/eu.chainfire.supersu'
		run_script;
	  ;;
	  grx_ajustes)
		ruta='codePath="/data/app/com.mods.grx.grxajustes'
		run_script;
		ruta='codePath="/system/app/GrxAjustes'
		run_script;
		ruta='codePath="/system/priv-app/GrxAjustes'
		run_script;
	  ;;
	  ajustes_tw)
		ruta='codePath="/system/app/AjustesTouchWizGrx'
		run_script;
		ruta='codePath="/system/priv-app/AjustesTouchWizGrx'
		run_script;
		ruta='codePath="/data/app/com.mods.grx.grxajustes.touchwizhome'
		run_script;
	  ;;
	  synapse)
		ruta='codePath="/data/app/com.moro.synapsemod'
		run_script;
		ruta='codePath="/data/app/com.af.synapse'
		run_script;
		ruta='codePath="/system/priv-app/Synapse'
		run_script;
		ruta='codePath="/system/app/Synapse'
		run_script;
	  ;;
	  mtweaks)
		ruta='codePath="/system/app/com.moro.mtweaks'
		run_script;
		ruta='codePath="/system/priv-app/com.moro.mtweaks'
		run_script;
		ruta='codePath="/data/app/com.moro.mtweaks'
		run_script;
	  ;;
	  spectrum)
		ruta='codePath="/data/app/org.frap129.spectrum'
		run_script;
	  ;;
	esac;
fi	
	

