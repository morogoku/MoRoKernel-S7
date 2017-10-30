#!/bin/bash
#
# Thanks to Tkkg1994 and djb77 for the script
#
# MoRoKernel Build Script v1.6
#

# SETUP
# -----
export ARCH=arm64
export SUBARCH=arm64
#export BUILD_CROSS_COMPILE=/home/moro/kernel/toolchains/aarch64-linux-android-4.9/bin/aarch64-linux-android-
#export BUILD_CROSS_COMPILE=/home/moro/kernel/toolchains/aarch64-linaro-6.3/bin/aarch64-
#export BUILD_CROSS_COMPILE=/home/moro/kernel/toolchains/aarch64-cortex_a53-linux-gnueabi-GNU-6.3.0/bin/aarch64-cortex_a53-linux-gnueabi-
export BUILD_CROSS_COMPILE=/home/moro/kernel/toolchains/aarch64-ubertc-6.3.1-20170503/bin/aarch64-linux-android-
#export BUILD_CROSS_COMPILE=/home/moro/kernel/toolchains/aarch64-sabermod-7.0/bin/aarch64-
#export BUILD_CROSS_COMPILE=/home/moro/kernel/toolchains/aarch64-sabermod-5.4/bin/aarch64-
export CROSS_COMPILE=$BUILD_CROSS_COMPILE
export BUILD_JOB_NUMBER=`grep processor /proc/cpuinfo|wc -l`


RDIR=$(pwd)
OUTDIR=$RDIR/arch/$ARCH/boot
DTSDIR=$RDIR/arch/$ARCH/boot/dts
DTBDIR=$OUTDIR/dtb
DTCTOOL=$RDIR/scripts/dtc/dtc
INCDIR=$RDIR/include
PAGE_SIZE=2048
DTB_PADDING=0

DEFCONFIG=moro_defconfig
DEFCONFIG_S7EDGE=moro-edge_defconfig
DEFCONFIG_S7FLAT=moro-flat_defconfig
DEFCONFIG_S8EDGE=moro-edge-s8_defconfig
DEFCONFIG_S8FLAT=moro-flat-s8_defconfig

export K_VERSION="v2.1"
export REVISION="RC"
export KBUILD_BUILD_VERSION="1"
S7DEVICE="S7_Stock"
S8DEVICE="S8_N7_Port"
N8DEVICE="N8_Port"
EDGE_LOG=Edge_build.log
FLAT_LOG=Flat_build.log
PORT=0


# FUNCTIONS
# ---------
FUNC_DELETE_PLACEHOLDERS()
{
	find . -name \.placeholder -type f -delete
        echo "Placeholders Deleted from Ramdisk"
        echo ""
}

FUNC_CLEAN_DTB()
{
	if ! [ -d $RDIR/arch/$ARCH/boot/dts ] ; then
		echo "no directory : "$RDIR/arch/$ARCH/boot/dts""
	else
		echo "rm files in : "$RDIR/arch/$ARCH/boot/dts/*.dtb""
		rm $RDIR/arch/$ARCH/boot/dts/*.dtb
		rm $RDIR/arch/$ARCH/boot/dtb/*.dtb
		rm $RDIR/arch/$ARCH/boot/boot.img-dtb
		rm $RDIR/arch/$ARCH/boot/boot.img-zImage
	fi
}

FUNC_BUILD_KERNEL()
{
	echo ""
        echo "build common config="$KERNEL_DEFCONFIG ""
        echo "build variant config="$MODEL ""

	cp -f $RDIR/arch/$ARCH/configs/$DEFCONFIG $RDIR/arch/$ARCH/configs/tmp_defconfig
	cat $RDIR/arch/$ARCH/configs/$KERNEL_DEFCONFIG >> $RDIR/arch/$ARCH/configs/tmp_defconfig

	FUNC_CLEAN_DTB

	make -j$BUILD_JOB_NUMBER ARCH=$ARCH \
			CROSS_COMPILE=$BUILD_CROSS_COMPILE \
			tmp_defconfig || exit -1
	make -j$BUILD_JOB_NUMBER ARCH=$ARCH \
			CROSS_COMPILE=$BUILD_CROSS_COMPILE || exit -1
	echo ""

	rm -f $RDIR/arch/$ARCH/configs/tmp_defconfig
}

FUNC_BUILD_DTB()
{
	[ -f "$DTCTOOL" ] || {
		echo "You need to run ./build.sh first!"
		exit 1
	}
	case $MODEL in
	G930)
		DTSFILES="exynos8890-herolte_eur_open_00 exynos8890-herolte_eur_open_01
				exynos8890-herolte_eur_open_02 exynos8890-herolte_eur_open_03
				exynos8890-herolte_eur_open_04 exynos8890-herolte_eur_open_08
				exynos8890-herolte_eur_open_09"
		;;
	G935)
		DTSFILES="exynos8890-hero2lte_eur_open_00 exynos8890-hero2lte_eur_open_01
				exynos8890-hero2lte_eur_open_03 exynos8890-hero2lte_eur_open_04
				exynos8890-hero2lte_eur_open_08"
		;;
	*)
		echo "Unknown device: $MODEL"
		exit 1
		;;
	esac
	mkdir -p $OUTDIR $DTBDIR
	cd $DTBDIR || {
		echo "Unable to cd to $DTBDIR!"
		exit 1
	}
	rm -f ./*
	echo "Processing dts files."
	for dts in $DTSFILES; do
		echo "=> Processing: ${dts}.dts"
		${CROSS_COMPILE}cpp -nostdinc -undef -x assembler-with-cpp -I "$INCDIR" "$DTSDIR/${dts}.dts" > "${dts}.dts"
		echo "=> Generating: ${dts}.dtb"
		$DTCTOOL -p $DTB_PADDING -i "$DTSDIR" -O dtb -o "${dts}.dtb" "${dts}.dts"
	done
	echo "Generating dtb.img."
	$RDIR/scripts/dtbTool/dtbTool -o "$OUTDIR/dtb.img" -d "$DTBDIR/" -s $PAGE_SIZE
	echo "Done."
}

FUNC_BUILD_RAMDISK()
{
	echo ""
	echo "Building Ramdisk"
	mv $RDIR/arch/$ARCH/boot/Image $RDIR/arch/$ARCH/boot/boot.img-zImage
	mv $RDIR/arch/$ARCH/boot/dtb.img $RDIR/arch/$ARCH/boot/boot.img-dtb
	
	cd $RDIR/build
	mkdir temp
	cp -rf aik/. temp
	cp -rf ramdisk/. temp
	
	rm -f temp/split_img/boot.img-zImage
	rm -f temp/split_img/boot.img-dtb
	mv $RDIR/arch/$ARCH/boot/boot.img-zImage temp/split_img/boot.img-zImage
	mv $RDIR/arch/$ARCH/boot/boot.img-dtb temp/split_img/boot.img-dtb
	cd temp

	if [ $PORT == "1" ]; then
		echo "Ramdisk PortS8 NoteFE"
		cp -rf $RDIR/build/ramdisk_ports8/. ramdisk
	elif [ $PORT == "2" ]; then
		echo "Ramdisk PortN8"
		cp -rf $RDIR/build/ramdisk_portn8/. ramdisk
	fi

	case $MODEL in
	G935)
		echo "Ramdisk for G935"
		if [ $PORT == "1" ]; then
			sed -i 's/G935/G955/g' ramdisk/default.prop
			sed -i 's/hero2/dream2/g' ramdisk/default.prop
			sed -i 's/hero2/dream2/g' ramdisk/property_contexts
			sed -i 's/hero2/dream2/g' ramdisk/service_contexts
		fi
		;;
	G930)
		echo "Ramdisk for G930"
		sed -i '/sys\/class\/lcd\/panel\/mcd_mode/d' ramdisk/init.samsungexynos8890.rc
		sed -i 's/SRPOI30A000KU/SRPOI17A000KU/g' split_img/boot.img-board

		if [ $PORT == "1" ]; then
			sed -i 's/G935/G955/g' ramdisk/default.prop
			sed -i 's/hero2/dream2/g' ramdisk/default.prop
			sed -i 's/hero2/dream2/g' ramdisk/property_contexts
			sed -i 's/hero2/dream2/g' ramdisk/service_contexts
		elif [ $PORT == "0" ]; then
			sed -i 's/G935/G930/g' ramdisk/default.prop
			sed -i 's/hero2/hero/g' ramdisk/default.prop
			sed -i 's/hero2/hero/g' ramdisk/property_contexts
			sed -i 's/hero2/hero/g' ramdisk/service_contexts
		fi
		;;
	esac

		echo "Done"

	./repackimg.sh

	cp -f image-new.img $RDIR/build
	cd ..
	rm -rf temp
	echo SEANDROIDENFORCE >> image-new.img
	mv image-new.img $MODEL-boot.img
}

FUNC_BUILD_FLASHABLES()
{
	cd $RDIR/build
	mkdir temp2
	cp -rf zip/common/. temp2
	if [ $PORT == "1" ]; then
    	    cp -rf zip/s8/. temp2
	else
	    cp -rf zip/s7/. temp2
	fi
    	mv *.img temp2/
	cd temp2
	echo ""
	echo "Compressing kernels..."
	tar cv *.img | xz -9 > kernel.tar.xz
	mv kernel.tar.xz moro/
	rm -f *.img
	if [ $prompt == "3" ]; then
	    zip -9 -r ../MoRoKernel-$DEVICE-N-$K_VERSION.zip *
	elif [ $prompt == "6" ]; then
	    zip -9 -r ../MoRoKernel-$DEVICE-N-$K_VERSION.zip *
	elif [ $prompt == "9" ]; then
	    zip -9 -r ../MoRoKernel-$DEVICE-N-$K_VERSION.zip *
	else
	    zip -9 -r ../MoRoKernel-$MODEL-$DEVICE-N-$K_VERSION.zip *
	fi
	cd ..
    	rm -rf temp2
}



# MAIN PROGRAM
# ------------

MAIN()
{

(
	START_TIME=`date +%s`
	FUNC_DELETE_PLACEHOLDERS
	FUNC_BUILD_KERNEL
	FUNC_BUILD_DTB
	FUNC_BUILD_RAMDISK
	FUNC_BUILD_FLASHABLES
	END_TIME=`date +%s`
	let "ELAPSED_TIME=$END_TIME-$START_TIME"
	echo "Total compile time is $ELAPSED_TIME seconds"
	echo ""
) 2>&1 | tee -a ./$LOG

	echo "Your flasheable release can be found in the build folder"
	echo ""
}

MAIN2()
{

(
	START_TIME=`date +%s`
	FUNC_DELETE_PLACEHOLDERS
	FUNC_BUILD_KERNEL
	FUNC_BUILD_DTB
	FUNC_BUILD_RAMDISK
	END_TIME=`date +%s`
	let "ELAPSED_TIME=$END_TIME-$START_TIME"
	echo "Total compile time is $ELAPSED_TIME seconds"
	echo ""
) 2>&1 | tee -a ./$LOG

	echo "Your flasheable release can be found in the build folder"
	echo ""
}


# PROGRAM START
# -------------
clear
echo "***********************"
echo "MoRoKernel Build Script"
echo "***********************"
echo ""
echo ""
echo "Build Kernel for:"
echo ""
echo "S7 Stock"
echo "(1) S7 Flat SM-G930F"
echo "(2) S7 Edge SM-G935F"
echo "(3) S7 Edge + Flat"
echo ""
echo "Port S8"
echo "(4) S7 Flat SM-G930F"
echo "(5) S7 Edge SM-G935F"
echo "(6) S7 Edge + Flat"
echo ""
echo "Port N8"
echo "(7) S7 Flat SM-G930F"
echo "(8) S7 Edge SM-G935F"
echo "(9) S7 Edge + Flat"
echo ""
read -p "Select an option to compile the kernel " prompt


if [ $prompt == "1" ]; then
    export MODEL=G930
    export DEVICE=$S7DEVICE
    KERNEL_DEFCONFIG=$DEFCONFIG_S7FLAT
    LOG=$FLAT_LOG
    export KERNEL_VERSION="MoRoKernel-$MODEL-$DEVICE-N-$K_VERSION"
    echo "S7 Flat G930F Selected"
    MAIN
elif [ $prompt == "2" ]; then
    MODEL=G935
    DEVICE=$S7DEVICE
    KERNEL_DEFCONFIG=$DEFCONFIG_S7EDGE
    LOG=$EDGE_LOG
    export KERNEL_VERSION="MoRoKernel-$MODEL-$DEVICE-N-$K_VERSION"
    echo "S7 Edge G935F Selected"
    MAIN
elif [ $prompt == "3" ]; then
    MODEL=G935
    DEVICE=$S7DEVICE
    KERNEL_DEFCONFIG=$DEFCONFIG_S7EDGE
    LOG=$EDGE_LOG
    export KERNEL_VERSION="MoRoKernel-$MODEL-$DEVICE-N-$K_VERSION"
    echo "S7 EDGE + FLAT Selected"
    echo "Compiling EDGE ..."
    MAIN2
    MODEL=G930
    KERNEL_DEFCONFIG=$DEFCONFIG_S7FLAT
    LOG=$FLAT_LOG
    export KERNEL_VERSION="MoRoKernel-$MODEL-$DEVICE-N-$K_VERSION"
    echo "Compiling FLAT ..."
    MAIN
elif [ $prompt == "4" ]; then
    MODEL=G930
    PORT=1
    DEVICE=$S8DEVICE
    KERNEL_DEFCONFIG=$DEFCONFIG_S8FLAT
    LOG=$FLAT_LOG
    export KERNEL_VERSION="MoRoKernel-$MODEL-$DEVICE-N-$K_VERSION"
    echo "S7 Flat G930F Port S8-NoteFE Selected"
    MAIN
elif [ $prompt == "5" ]; then
    MODEL=G935
    PORT=1
    DEVICE=$S8DEVICE
    KERNEL_DEFCONFIG=$DEFCONFIG_S8EDGE
    LOG=$EDGE_LOG
    export KERNEL_VERSION="MoRoKernel-$MODEL-$DEVICE-N-$K_VERSION"
    echo "S7 Edge G935F Port S8-NoteFE Selected"
    MAIN
elif [ $prompt == "6" ]; then
    MODEL=G935
    PORT=1
    DEVICE=$S8DEVICE
    KERNEL_DEFCONFIG=$DEFCONFIG_S8EDGE
    LOG=$EDGE_LOG
    export KERNEL_VERSION="MoRoKernel-$MODEL-$DEVICE-N-$K_VERSION"
    echo "S7 EDGE + FLAT Port S8-NoteFE"
    echo "Compiling EDGE ..."
    MAIN2
    MODEL=G930
    KERNEL_DEFCONFIG=$DEFCONFIG_S8FLAT
    LOG=$FLAT_LOG
    export KERNEL_VERSION="MoRoKernel-$MODEL-$DEVICE-N-$K_VERSION"
    echo "Compiling FLAT ..."
    MAIN
elif [ $prompt == "7" ]; then
    MODEL=G930
    PORT=2
    DEVICE=$N8DEVICE
    KERNEL_DEFCONFIG=$DEFCONFIG_S8FLAT
    LOG=$FLAT_LOG
    export KERNEL_VERSION="MoRoKernel-$MODEL-$DEVICE-N-$K_VERSION"
    echo "S7 Flat G930F Port N8 Selected"
    MAIN
elif [ $prompt == "8" ]; then
    MODEL=G935
    PORT=2
    DEVICE=$N8DEVICE
    KERNEL_DEFCONFIG=$DEFCONFIG_S8EDGE
    LOG=$EDGE_LOG
    export KERNEL_VERSION="MoRoKernel-$MODEL-$DEVICE-N-$K_VERSION"
    echo "S7 Edge G935F Port N8 Selected"
    MAIN
elif [ $prompt == "9" ]; then
    MODEL=G935
    PORT=2
    DEVICE=$N8DEVICE
    KERNEL_DEFCONFIG=$DEFCONFIG_S8EDGE
    LOG=$EDGE_LOG
    export KERNEL_VERSION="MoRoKernel-$MODEL-$DEVICE-N-$K_VERSION"
    echo "S7 EDGE + FLAT Port N8"
    echo "Compiling EDGE ..."
    MAIN2
    MODEL=G930
    KERNEL_DEFCONFIG=$DEFCONFIG_S8FLAT
    LOG=$FLAT_LOG
    export KERNEL_VERSION="MoRoKernel-$MODEL-$DEVICE-N-$K_VERSION"
    echo "Compiling FLAT ..."
    MAIN
fi


