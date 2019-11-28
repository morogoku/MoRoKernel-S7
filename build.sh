#!/bin/bash
#
# Thanks to Tkkg1994, djb77 and Morogoku for the script
#
#  ED7GE Build Script v1.00
#


# SETUP
# -----
export ARCH=arm64
export SUBARCH=arm64

GCC_PATH=/home/moro/kernel/toolchains/aarch64-linux-android-4.9
CLANG_PATH=/home/moro/kernel/toolchains/clang-10.0.1-r370808
#CLANG_PATH=/home/moro/kernel/toolchains/clang-6.0.2-4691093

CLANG="yes"
BUILD_CC=$CLANG_PATH/bin/clang
BUILD_CLANG_TRIPLE=$CLANG_PATH/bin/aarch64-linux-gnu-
BUILD_CROSS_COMPILE=$GCC_PATH/bin/aarch64-linux-android-

export BUILD_JOB_NUMBER=`grep processor /proc/cpuinfo|wc -l`

export ANDROID_MAJOR_VERSION=p 
export ANDROID_VERSION=90000 
export PLATFORM_VERSION=9.0.0


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

# VERSION KERNEL
# --------------
K_VERSION="v8.0b04"
K_SUBVER="6"
K_BASE="CSK1"
K_NAME="MoRoKernel"
K_OS="twPie"

export KERNEL_VERSION="$K_SUBVER-$K_NAME-$K_OS-$K_BASE-$K_VERSION"
export KBUILD_BUILD_VERSION="1"

EDGE_LOG=Edge_build.log
FLAT_LOG=Flat_build.log


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
        echo "Model: $MODEL"
        echo "build common config="$DEFCONFIG""
        echo "build variant config="$KERNEL_DEFCONFIG""

	cp -f $RDIR/arch/$ARCH/configs/$DEFCONFIG $RDIR/arch/$ARCH/configs/tmp_defconfig
	cat $RDIR/arch/$ARCH/configs/$KERNEL_DEFCONFIG >> $RDIR/arch/$ARCH/configs/tmp_defconfig
	

	#FUNC_CLEAN_DTB

	make -j$BUILD_JOB_NUMBER ARCH=$ARCH \
			tmp_defconfig || exit -1

	if [ $CLANG == "yes" ]; then
		make -j$BUILD_JOB_NUMBER ARCH=$ARCH \
				CC=$BUILD_CC \
				CLANG_TRIPLE=$BUILD_CLANG_TRIPLE \
				CROSS_COMPILE=$BUILD_CROSS_COMPILE || exit -1
	else
		make -j$BUILD_JOB_NUMBER ARCH=$ARCH \
				CROSS_COMPILE=$BUILD_CROSS_COMPILE || exit -1
	fi
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
		DTSFILES="exynos8890-herolte_eur_open_04 exynos8890-herolte_eur_open_08
				exynos8890-herolte_eur_open_09 exynos8890-herolte_eur_open_10"
		;;
	G935)
		DTSFILES="exynos8890-hero2lte_eur_open_04 exynos8890-hero2lte_eur_open_08"
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
	$RDIR/scripts/dtbtool_exynos/dtbtool -o "$OUTDIR/dtb.img" -d "$DTBDIR/" -s $PAGE_SIZE
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
	mv $RDIR/arch/$ARCH/boot/boot.img-dtb temp/split_img/boot.img-dt
	cd temp

	case $MODEL in
	G935)
		echo "Ramdisk for G935"
		;;
	G930)
		echo "Ramdisk for G930"
		sed -i 's/G935/G930/g' ramdisk/default.prop
		sed -i 's/hero2/hero/g' ramdisk/default.prop
		;;
	esac

		echo "Done"

	./repackimg.sh

	echo SEANDROIDENFORCE >> image-new.img
	mv image-new.img $RDIR/build/$K_NAME-$K_OS-$K_BASE-$K_VERSION.img
	rm -rf $RDIR/build/temp
}

FUNC_BUILD_FLASHABLES()
{
	cd $RDIR/build
	mkdir temp2
	cp -rf zip/common/. temp2
	mv *.img temp2/
	cd temp2
	echo ""
	echo "Compressing kernels..."
	tar cv *.img | xz -9 > kernel.tar.xz
	mv kernel.tar.xz moro/
	rm -f *.img

	zip -9 -r ../$ZIP_NAME *

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
	#FUNC_BUILD_FLASHABLES
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
echo "*************************"
echo "ED7GE Kernel Build Script"
echo "*************************"
echo ""
echo ""
echo "Build Kernel for:"
echo ""
echo "(1) S7 Flat SM-G930F"
echo "(2) S7 Edge SM-G935F"
echo "(3) S7 Edge + Flat"
echo ""
read -p "Select an option to compile the kernel " prompt


if [ $prompt == "1" ]; then
    MODEL=G930
    KERNEL_DEFCONFIG=$DEFCONFIG_S7FLAT
    LOG=$FLAT_LOG
    echo "S7 Flat G930F Selected"
    ZIP_NAME=$K_NAME-P-$MODEL-$K_VERSION.zip
    MAIN
elif [ $prompt == "2" ]; then
    MODEL=G935
    KERNEL_DEFCONFIG=$DEFCONFIG_S7EDGE
    LOG=$EDGE_LOG
    echo "S7 Edge G935F Selected"
    ZIP_NAME=$K_NAME-P-$MODEL-$K_VERSION.zip
    MAIN
elif [ $prompt == "3" ]; then
    MODEL=G935
    DEVICE2=G93X
    KERNEL_DEFCONFIG=$DEFCONFIG_S7EDGE
    LOG=$EDGE_LOG
    echo "S7 EDGE + FLAT Selected"
    echo "Compiling EDGE ..."
    MAIN2
    MODEL=G930
    KERNEL_DEFCONFIG=$DEFCONFIG_S7FLAT
    LOG=$FLAT_LOG
    echo "Compiling FLAT ..."
    ZIP_NAME=$K_NAME-P-$DEVICE2-$K_VERSION.zip
    MAIN
fi


