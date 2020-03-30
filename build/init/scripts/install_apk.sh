#!/system/bin/sh
#
# install apk script by morogoku
#


echo "## -- Start Install APK" >> $LOG;

if [ ! -d $MORO_DIR/apk ]; then
    mkdir -p $MORO_DIR/apk;
fi

# Remove tmp app on data/app
rm -Rf /data/app/*.tmp

chown -R root.root $MORO_DIR/apk;
chmod 777 $MORO_DIR/apk;

if [ "$(ls -A /$MORO_DIR/apk)" ]; then
    cd $MORO_DIR/apk;
    chmod 777 *;
    for apk in *.apk; do
        echo "## Install $apk" >> $LOG;
        pm install -r $apk;
        rm $apk;
    done;
else
    echo "## No files found" >> $LOG;
fi

echo "## -- End Install APK" >> $LOG;
echo " " >> $LOG;
