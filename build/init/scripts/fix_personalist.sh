#!/system/bin/sh
#
# init.d script by morogoku
#


echo "## -- Start Fix personalist" >> $LOG;

if [ ! -f /data/system/users/0/personalist.xml ]; then
    touch /data/system/users/0/personalist.xml;
    chmod 600 /data/system/users/0/personalist.xml;
    chown system:system /data/system/users/0/personalist.xml;
fi

echo "## -- End Fix personalist" >> $LOG;
echo " " >> $LOG;
