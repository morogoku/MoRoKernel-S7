#!/bin/bash
#
# Thanks to Tkkg1994 and djb77 for the script
#
# Script MoRoKernel v1.2
#

# SETUP
# -----
export ARCH=arm64
export SUBARCH=arm64
#export BUILD_CROSS_COMPILE=/home/moro/kernel/toolchains/aarch64-linux-android-4.9/bin/aarch64-linux-android-
#export BUILD_CROSS_COMPILE=/home/moro/kernel/toolchains/aarch64-linaro-6.3/bin/aarch64-
#export BUILD_CROSS_COMPILE=/home/moro/kernel/toolchains/aarch64-cortex_a53-linux-gnueabi-GNU-6.3.0/bin/aarch64-cortex_a53-linux-gnueabi-
export BUILD_CROSS_COMPILE=/home/moro/kernel/toolchains/aarch64-linux-android-6.x/bin/aarch64-linux-android-
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

# PROGRAM START
# -------------
clear
echo "**********************"
echo "MoRoKernel Build Script"
echo "**********************"
echo "Script originally written by Tkkg1994, modified by djb77"
echo "Remodified by morogoku with script of Javilonas"
echo ""
echo "Build Kernel for:"
echo ""
echo "(1)- S7 SM-G930F"
echo "(2)- S7 Edge-SM-G935F"
echo ""
read -p "Build Kernel for (1) S7 or (2) S7 Edge? " prompt

if [ $prompt == "1" ]; then
    export MODEL=G930F
    export MODEL2=G930F_S8
    KERNEL_DEFCONFIG=moro-herolte_defconfig
    echo "S7 Flat G930F Selected"
else [ $prompt == "2" ]
    export MODEL=G935F
    export MODEL2=G935F_S8
    KERNEL_DEFCONFIG=moro-hero2lte_defconfig
    echo "S7 Edge G935F Selected"
fi

export K_VERSION="v1.8"
export KERNEL_VERSION="MoRoKernel-$MODEL-N-$K_VERSION"
export KERNEL_VERSION2=MK-$MODEL-N-S8Port-$K_VERSION
export REVISION="RC"
export KBUILD_BUILD_VERSION="1"


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
	FUNC_CLEAN_DTB
	make -j$BUILD_JOB_NUMBER ARCH=$ARCH \
			CROSS_COMPILE=$BUILD_CROSS_COMPILE \
			$KERNEL_DEFCONFIG || exit -1
	make -j$BUILD_JOB_NUMBER ARCH=$ARCH \
			CROSS_COMPILE=$BUILD_CROSS_COMPILE || exit -1
	echo ""
}

FUNC_BUILD_DTB()
{
	[ -f "$DTCTOOL" ] || {
		echo "You need to run ./build.sh first!"
		exit 1
	}
	case $MODEL in
	G930F)
		DTSFILES="exynos8890-herolte_eur_open_00 exynos8890-herolte_eur_open_01
				exynos8890-herolte_eur_open_02 exynos8890-herolte_eur_open_03
				exynos8890-herolte_eur_open_04 exynos8890-herolte_eur_open_08
				exynos8890-herolte_eur_open_09"
		;;
	G935F)
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
	$RDIR/tools/dtbtool -o "$OUTDIR/dtb.img" -p "$DTBDIR/" -s $PAGE_SIZE
	echo "Done."
}

FUNC_BUILD_RAMDISK()
{
	mv $RDIR/arch/$ARCH/boot/Image $RDIR/arch/$ARCH/boot/boot.img-zImage
	mv $RDIR/arch/$ARCH/boot/dtb.img $RDIR/arch/$ARCH/boot/boot.img-dtb

	# S7 version
	rm -f $RDIR/ramdisk/$MODEL/split_img/boot.img-zImage
	rm -f $RDIR/ramdisk/$MODEL/split_img/boot.img-dtb
	cp -f $RDIR/arch/$ARCH/boot/boot.img-zImage $RDIR/ramdisk/$MODEL/split_img/boot.img-zImage
	cp -f $RDIR/arch/$ARCH/boot/boot.img-dtb $RDIR/ramdisk/$MODEL/split_img/boot.img-dtb
	cd $RDIR/ramdisk/$MODEL
	./repackimg.sh
	echo SEANDROIDENFORCE >> image-new.img

	# PortS8 version
	rm -f $RDIR/ramdisk/$MODEL2/split_img/boot.img-zImage
	rm -f $RDIR/ramdisk/$MODEL2/split_img/boot.img-dtb
	mv -f $RDIR/arch/$ARCH/boot/boot.img-zImage $RDIR/ramdisk/$MODEL2/split_img/boot.img-zImage
	mv -f $RDIR/arch/$ARCH/boot/boot.img-dtb $RDIR/ramdisk/$MODEL2/split_img/boot.img-dtb
	cd $RDIR/ramdisk/$MODEL2
	./repackimg.sh
	echo SEANDROIDENFORCE >> image-new.img
}

FUNC_BUILD_FLASHABLES()
{
    # S7 version
    cp $RDIR/ramdisk/$MODEL/image-new.img $RDIR/release/$MODEL/boot.img

    mkdir $RDIR/release/build
    cd $RDIR/release
    cp -R common/* build
    cp -R $MODEL/* build
    cd build
    zip -9 -r $RDIR/release/$KERNEL_VERSION.zip *
    rm $RDIR/release/$MODEL/boot.img
    rm -rf $RDIR/release/build

    # PortS8 version
    cp $RDIR/ramdisk/$MODEL2/image-new.img $RDIR/release/$MODEL2/boot.img

    mkdir $RDIR/release/build
    cd $RDIR/release
    cp -R common/* build
    cp -R $MODEL2/* build
    cd build
    zip -9 -r $RDIR/release/$KERNEL_VERSION2.zip *
    rm $RDIR/release/$MODEL2/boot.img
    rm -rf $RDIR/release/build
}

# MAIN PROGRAM
# ------------

(
	sh ./clean.sh
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
) 2>&1 | tee -a ./build.log

	echo "Your flasheable release can be found in the release/$MODEL and $MODEL2 folder"
	echo ""


