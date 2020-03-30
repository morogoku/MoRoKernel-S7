#!/system/bin/sh
#
# init.d script by morogoku
#


echo "## -- Start Init.d support" >> $LOG;

if [ ! -d /system/etc/init.d ]; then
    mkdir -p /system/etc/init.d;
fi

chown -R root.root /system/etc/init.d;
chmod 777 /system/etc/init.d;

# remove scripts
rm -f /system/etc/init.d/ts_swapoff.sh 2>/dev/null;
rm -f /system/etc/init.d/feravolt_gms.sh 2>/dev/null;
rm -f /system/etc/init.d/tskillgooogle.sh 2>/dev/null;
rm -f /system/etc/init.d/*detach* 2>/dev/null;
rm -f /system/su.d/*detach* 2>/dev/null;


if [ "$(ls -A /system/etc/init.d)" ]; then
    chmod 777 /system/etc/init.d/*;

    for FILE in /system/etc/init.d/*; do
        echo "## Executing init.d script: $FILE" >> $LOG;
        sh $FILE >/dev/null;
    done;
else
    echo "## No files found" >> $LOG;
fi

echo "## -- End Init.d support" >> $LOG;
echo " " >> $LOG;
