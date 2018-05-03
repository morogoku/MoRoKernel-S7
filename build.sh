#!/bin/bash
#
# Thanks to Tkkg1994 and djb77 for the script
#
# MoRoKernel Build Script v1.2
#

# SETUP
# -----
export ARCH=arm64
export SUBARCH=arm64
export BUILD_CROSS_COMPILE=/home/moro/kernel/toolchains/aarch64-linux-android-4.9/bin/aarch64-linux-android-
export CROSS_COMPILE=$BUILD_CROSS_COMPILE
export BUILD_JOB_NUMBER=`grep processor /proc/cpuinfo|wc -l`

export PLATFORM_VERSION=8.0.0

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

export K_VERSION="v3.0"
export K_NAME="MoRoKernel"
export REVISION="RC"
export KBUILD_BUILD_VERSION="1"
S7DEVICE="OREO"
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

	#FUNC_CLEAN_DTB

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
	#mv $RDIR/arch/$ARCH/boot/dtb.img $RDIR/arch/$ARCH/boot/boot.img-dtb
	
	cd $RDIR/build
	mkdir temp
	cp -rf aik/. temp
	cp -rf ramdisk/. temp
	
	rm -f temp/split_img/boot.img-zImage
	rm -f temp/split_img/boot.img-dtb
	mv $RDIR/arch/$ARCH/boot/boot.img-zImage temp/split_img/boot.img-zImage
	#mv $RDIR/arch/$ARCH/boot/boot.img-dtb temp/split_img/boot.img-dtb
	cd temp

	case $MODEL in
	G935)
		echo "Ramdisk for G935"
		cp -f split_img/boot.img-dtb-EDGE split_img/boot.img-dtb
		;;
	G930)
		echo "Ramdisk for G930"
		cp -f split_img/boot.img-dtb-FLAT split_img/boot.img-dtb

		sed -i 's/SRPOI30A000KU/SRPOI17A000KU/g' split_img/boot.img-board

		sed -i 's/G935/G930/g' ramdisk/default.prop
		sed -i 's/hero2/hero/g' ramdisk/default.prop
		;;
	esac

		echo "Done"

	./repackimg.sh

	cp -f image-new.img $RDIR/build
	cd ..
	rm -rf temp
	echo SEANDROIDENFORCE >> image-new.img
	#mv image-new.img $MODEL-boot.img
	mv image-new.img boot.img
}

FUNC_BUILD_FLASHABLES()
{
	cd $RDIR/build
	mkdir temp2
	cp -rf zip/common/. temp2
    	mv *.img temp2/
	cd temp2
	#echo ""
	#echo "Compressing kernels..."
	#tar cv *.img | xz -9 > kernel.tar.xz
	#mv kernel.tar.xz moro/
	#rm -f *.img

	zip -9 -r ../$ZIP_NAME *

	cd ..
    	rm -rf temp2

	if [ -n `which java` ]; then
		echo "- Java detected, signing zip ..."
		mv $ZIP_NAME old$ZIP_NAME
		java -Xmx1024m -jar $RDIR/build/signapk/signapk.jar -w $RDIR/build/signapk/testkey.x509.pem $RDIR/build/signapk/testkey.pk8 old$ZIP_NAME $ZIP_NAME
		rm old$ZIP_NAME
	fi
}



# MAIN PROGRAM
# ------------

MAIN()
{

(
	START_TIME=`date +%s`
	FUNC_DELETE_PLACEHOLDERS
	FUNC_BUILD_KERNEL
	#FUNC_BUILD_DTB
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
	#FUNC_BUILD_DTB
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
echo "S7 Oreo"
echo "(1) S7 Flat SM-G930F"
echo "(2) S7 Edge SM-G935F"
echo "(3) S7 Edge + Flat"
echo ""
echo ""
read -p "Select an option to compile the kernel " prompt


if [ $prompt == "1" ]; then
    export MODEL=G930
    export DEVICE=$S7DEVICE
    KERNEL_DEFCONFIG=$DEFCONFIG_S7FLAT
    LOG=$FLAT_LOG
    export KERNEL_VERSION="$K_NAME-$MODEL-$DEVICE-N-$K_VERSION"
    echo "S7 Flat G930F Selected"
    ZIP_NAME=$KERNEL_VERSION.zip
    MAIN
elif [ $prompt == "2" ]; then
    MODEL=G935
    DEVICE=$S7DEVICE
    KERNEL_DEFCONFIG=$DEFCONFIG_S7EDGE
    LOG=$EDGE_LOG
    export KERNEL_VERSION="$K_NAME-$MODEL-$DEVICE-N-$K_VERSION"
    echo "S7 Edge G935F Selected"
    ZIP_NAME=$KERNEL_VERSION.zip
    MAIN
elif [ $prompt == "3" ]; then
    MODEL=G935
    DEVICE=$S7DEVICE
    KERNEL_DEFCONFIG=$DEFCONFIG_S7EDGE
    LOG=$EDGE_LOG
    export KERNEL_VERSION="$K_NAME-$MODEL-$DEVICE-N-$K_VERSION"
    echo "S7 EDGE + FLAT Selected"
    echo "Compiling EDGE ..."
    MAIN2
    MODEL=G930
    KERNEL_DEFCONFIG=$DEFCONFIG_S7FLAT
    LOG=$FLAT_LOG
    export KERNEL_VERSION="$K_NAME-$MODEL-$DEVICE-N-$K_VERSION"
    echo "Compiling FLAT ..."
    ZIP_NAME=$K_NAME-$DEVICE-N-$K_VERSION.zip
    MAIN
fi


