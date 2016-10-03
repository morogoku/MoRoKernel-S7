#!/bin/bash
# kernel build script by Tkkg1994 v0.4 (optimized from apq8084 kernel source)
# Modified by djb77 / XDA Developers
# Remodified by morogoku /EspDesarrolladores

# SETUP
# -----
export MODEL=hero2lte
export ARCH=arm64
export SUBARCH=arm64
export BUILD_CROSS_COMPILE=/home/moro/kernel/toolchains/aarch64-sabermod-7.0/bin/aarch64-
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
rm -rf ./build.log
clear
echo "**********************"
echo "MoRoKernel Build Script"
echo "**********************"
echo "Script originally written by Tkkg1994, modified by djb77"
echo "Remodified by morogoku with script of Javilonas"
echo ""
read -p "Build Kernel for (1) S7 or (2) S7 Edge? " prompt
if [ $prompt == "2" ]
then
	export MODEL=hero2lte
	
fi
if [ $MODEL = herolte ]
then
	KERNEL_DEFCONFIG=moro_herolte_defconfig
	export VERSION_KL="G930F"
	echo "S7 Selected"
	echo ""
else [ $MODEL = hero2lte ]
	KERNEL_DEFCONFIG=moro_hero2lte_defconfig
	export VERSION_KL="G935F"
	echo "S7 Edge Selected"
	echo ""
fi

export KERNEL_VERSION="MoRoKernel-$VERSION_KL-v0.5"
export REVISION="RC"
export KBUILD_BUILD_VERSION="42"


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
	herolte)
		DTSFILES="exynos8890-herolte_eur_open_00 exynos8890-herolte_eur_open_01
				exynos8890-herolte_eur_open_02 exynos8890-herolte_eur_open_03
				exynos8890-herolte_eur_open_04 exynos8890-herolte_eur_open_08
				exynos8890-herolte_eur_open_09"
		;;
	hero2lte)
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
	mv $RDIR/arch/$ARCH/boot/Image $RDIR/arch/$ARCH/boot/boot.img-zImage
	mv $RDIR/arch/$ARCH/boot/dtb.img $RDIR/arch/$ARCH/boot/boot.img-dtb
	case $MODEL in
	herolte)
		rm -f $RDIR/ramdisk/G930F/split_img/boot.img-zImage
		rm -f $RDIR/ramdisk/G930F/split_img/boot.img-dtb
		mv -f $RDIR/arch/$ARCH/boot/boot.img-zImage $RDIR/ramdisk/G930F/split_img/boot.img-zImage
		mv -f $RDIR/arch/$ARCH/boot/boot.img-dtb $RDIR/ramdisk/G930F/split_img/boot.img-dtb
		cd $RDIR/ramdisk/G930F
		./repackimg.sh
		echo SEANDROIDENFORCE >> image-new.img
		;;
	hero2lte)
		rm -f $RDIR/ramdisk/G935F/split_img/boot.img-zImage
		rm -f $RDIR/ramdisk/G935F/split_img/boot.img-dtb
		mv -f $RDIR/arch/$ARCH/boot/boot.img-zImage $RDIR/ramdisk/G935F/split_img/boot.img-zImage
		mv -f $RDIR/arch/$ARCH/boot/boot.img-dtb $RDIR/ramdisk/G935F/split_img/boot.img-dtb
		cd $RDIR/ramdisk/G935F
		./repackimg.sh
		echo SEANDROIDENFORCE >> image-new.img
		;;
	*)
		echo "Unknown device: $MODEL"
		exit 1
		;;
	esac
}

FUNC_BUILD_FLASHABLES()
{
	cp image-new.img $RDIR/releasetools/zip/boot.img
	cp image-new.img $RDIR/releasetools/tar/boot.img

	cd $RDIR
	cd releasetools/zip
	zip -0 -r $KERNEL_VERSION-$REVISION$KBUILD_BUILD_VERSION.zip *
	rm boot.img
	cd ..
	cd tar
	tar cf $KERNEL_VERSION-$REVISION$KBUILD_BUILD_VERSION.tar boot.img && ls -lh $KERNEL_VERSION-$REVISION$KBUILD_BUILD_VERSION.tar
	rm boot.img

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
) 2>&1	 | tee -a ./build.log

	echo "Your flasheable release can be found in the releasetools/zip or tar folder"
	echo ""


