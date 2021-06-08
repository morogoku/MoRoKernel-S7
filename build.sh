#!/bin/bash
#
# Thanks to Tkkg1994 and djb77 for the script
#
# MoRoKernel Build Script
#

# SETUP
# -----
export ARCH=arm64
export SUBARCH=arm64
export BUILD_CROSS_COMPILE=/home/moro/kernel/toolchains/ubertc-6.5/bin/aarch64-linux-android-
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
DEFCONFIG_OREO=moro-oreo_defconfig
DEFCONFIG_PIE=moro-pie_defconfig
DEFCONFIG_S7EDGE=moro-edge_defconfig
DEFCONFIG_S7FLAT=moro-flat_defconfig
DEFCONFIG_N7FE=moro-grace_defconfig


K_VERSION="v8.8"
K_SUBVER="8"
K_BASE="CUA1"
K_NAME="MoRoKernel"
export KBUILD_BUILD_VERSION="1"


#
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
	if ! [ -d $DTSDIR ] ; then
		echo "no directory : "$DTSDIR""
	else
		echo "rm files in : "$RDIR/arch/$ARCH/boot/dts/*.dtb""
		rm $DTSDIR/*.dtb 2>/dev/null
		rm $DTBDIR/*.dtb 2>/dev/null
	fi
}

FUNC_BUILD_KERNEL()
{
	echo ""
	echo "Model: $MODEL"
	echo "OS: $OS"
	echo "GPU: $GPU"
        echo "build common config="$DEFCONFIG""
        echo "build variant config="$DEVICE_DEFCONFIG""

	cp -f $RDIR/arch/$ARCH/configs/$DEFCONFIG $RDIR/arch/$ARCH/configs/tmp_defconfig
	cat $RDIR/arch/$ARCH/configs/$OS_DEFCONFIG >> $RDIR/arch/$ARCH/configs/tmp_defconfig
	cat $RDIR/arch/$ARCH/configs/$DEVICE_DEFCONFIG >> $RDIR/arch/$ARCH/configs/tmp_defconfig

	# MTP
	if [[ $MTP == "aosp" ]]; then
		sed -i '/CONFIG_USB_ANDROID_SAMSUNG_MTP/c\# CONFIG_USB_ANDROID_SAMSUNG_MTP is not set' $RDIR/arch/$ARCH/configs/tmp_defconfig
	elif [[ $MTP == "sam" ]]; then
		sed -i '/CONFIG_USB_ANDROID_SAMSUNG_MTP/c\CONFIG_USB_ANDROID_SAMSUNG_MTP=y' $RDIR/arch/$ARCH/configs/tmp_defconfig
	fi

	# GPU driver
	if [[ $GPU == "r22" ]]; then
		sed -i '/CONFIG_MALI_R22P0/c\CONFIG_MALI_R22P0=y' $RDIR/arch/$ARCH/configs/tmp_defconfig
		sed -i '/CONFIG_MALI_R28P0/c\# CONFIG_MALI_R28P0 is not set' $RDIR/arch/$ARCH/configs/tmp_defconfig
		sed -i '/CONFIG_MALI_R29P0/c\# CONFIG_MALI_R29P0 is not set' $RDIR/arch/$ARCH/configs/tmp_defconfig
	elif [[ $GPU == "r28" ]]; then
		sed -i '/CONFIG_MALI_R22P0/c\# CONFIG_MALI_R22P0 is not set' $RDIR/arch/$ARCH/configs/tmp_defconfig
		sed -i '/CONFIG_MALI_R28P0/c\CONFIG_MALI_R28P0=y' $RDIR/arch/$ARCH/configs/tmp_defconfig
		sed -i '/CONFIG_MALI_R29P0/c\# CONFIG_MALI_R29P0 is not set' $RDIR/arch/$ARCH/configs/tmp_defconfig
	elif [[ $GPU == "r29" ]]; then
		sed -i '/CONFIG_MALI_R22P0/c\# CONFIG_MALI_R22P0 is not set' $RDIR/arch/$ARCH/configs/tmp_defconfig
		sed -i '/CONFIG_MALI_R28P0/c\# CONFIG_MALI_R28P0 is not set' $RDIR/arch/$ARCH/configs/tmp_defconfig
		sed -i '/CONFIG_MALI_R29P0/c\CONFIG_MALI_R29P0=y' $RDIR/arch/$ARCH/configs/tmp_defconfig
	fi
	
	# Selinux
	if [[ $PERMISSIVE == "yes" ]]; then
		sed -i '/CONFIG_ALWAYS_PERMISSIVE/c\CONFIG_ALWAYS_PERMISSIVE=y' $RDIR/arch/$ARCH/configs/tmp_defconfig
	elif [[ $PERMISSIVE == "no" ]]; then
		sed -i '/CONFIG_ALWAYS_PERMISSIVE/c\# CONFIG_ALWAYS_PERMISSIVE is not set' $RDIR/arch/$ARCH/configs/tmp_defconfig
	fi
	
	# HALL_EVENT_REVERSE for Q rom
	if [[ $OS == "twQ" || $OS == "los18" ]]; then
		sed -i '/CONFIG_HALL_EVENT_REVERSE/c\CONFIG_HALL_EVENT_REVERSE=y' $RDIR/arch/$ARCH/configs/tmp_defconfig
	fi
	
	# DTB
	if [[ $MODEL == "G935" || $MODEL == "G930" ]]; then
		cp $DTSDIR/exynos8890-herolte_$OS.dtsi $DTSDIR/exynos8890-herolte_common.dtsi
		echo "Used exynos8890-herolte_$OS.dtsi as exynos8890-herolte_common.dtsi"
	elif [[ $MODEL == "N935" || $MODEL == "N930" ]]; then
		cp $DTSDIR/exynos8890-gracelte_$OS.dtsi $DTSDIR/exynos8890-gracelte_common.dtsi
		echo "Used exynos8890-gracelte_$OS.dtsi as exynos8890-gracelte_common.dtsi"
	fi

	# COMPILE
	make -j$BUILD_JOB_NUMBER ARCH=$ARCH \
			CROSS_COMPILE=$BUILD_CROSS_COMPILE \
			tmp_defconfig || exit -1
	make -j$BUILD_JOB_NUMBER ARCH=$ARCH \
			CROSS_COMPILE=$BUILD_CROSS_COMPILE || exit -1
	echo ""

	rm -f $RDIR/arch/$ARCH/configs/tmp_defconfig 2>/dev/null
	rm -f $DTSDIR/exynos8890-herolte_common.dtsi 2>/dev/null
	rm -f $DTSDIR/exynos8890-gracelte_common.dtsi 2>/dev/null
}

FUNC_BUILD_RAMDISK()
{
	echo ""
	echo "Building Ramdisk"

		
	cd $RDIR/build
	mkdir temp 2>/dev/null
	cp -rf aik/. temp
	
	if [[ $MODEL == "N935" && $OS == "twPie" ]]; then
		cp -rf ramdisk/twPie-N935/ramdisk/. temp/ramdisk
		cp -rf ramdisk/twPie-N935/split_img/. temp/split_img
	else
		cp -rf ramdisk/$OS/ramdisk/. temp/ramdisk
		cp -rf ramdisk/$OS/split_img/. temp/split_img
	fi
	
	if [[ $OS != "twQ" && $OS != "los18" ]];then
		if [[ $OS == "treble" ]]; then
			cp -rf init/root_treble/. temp/ramdisk
		else
			cp -rf init/root_common/. temp/ramdisk
		fi
		
		cp -rf init/scripts/. temp/ramdisk/sbin
	fi
	
	rm -f temp/split_img/boot.img-zImage
	rm -f temp/split_img/boot.img-dt
	mv $RDIR/arch/$ARCH/boot/Image temp/split_img/boot.img-zImage
	mv $RDIR/arch/$ARCH/boot/dtb.img temp/split_img/boot.img-dt
	cd temp

	echo "Model: $MODEL, OS: $OS"

	./repackimg.sh

	echo SEANDROIDENFORCE >> image-new.img
	mkdir $RDIR/build/kernel-temp 2>/dev/null
	mv image-new.img $RDIR/build/kernel-temp/$MODEL-$OS-$GPU-boot.img
	rm -rf $RDIR/build/temp

}

FUNC_BUILD_FLASHABLES()
{
	cd $RDIR/build
	mkdir temp
	cp -rf zip/. temp
	
	cp -rf init/scripts/. temp/moro/files
	cp -rf init/sar/. temp/moro/files
	
	cd $RDIR/build/kernel-temp
	echo ""
	echo "Compressing kernels..."
	tar cv * | xz -9 > ../temp/moro/kernel.tar.xz

	cd $RDIR/build/temp
	zip -9 -r ../$ZIP_NAME *

	cd ..
	rm -rf temp kernel-temp ramdisk-temp
}


#
# MAIN PROGRAM
# ------------

MAIN()
{

# Export Android version variables
if [[ $ANDROID == "9" ]]; then
	export ANDROID_MAJOR_VERSION=p
	export ANDROID_VERSION=90000
	export PLATFORM_VERSION=9.0.0
elif [[ $ANDROID == "8" ]]; then
	export ANDROID_MAJOR_VERSION=o
	export ANDROID_VERSION=80000
	export PLATFORM_VERSION=8.0.0
fi

# Kernel name for Lineage 17 & 18 roms
if [[ $OS == "los18" ]];then
	export KERNEL_VERSION="$K_SUBVER-$K_NAME-los17/18-$K_BASE-$K_VERSION"
else
	export KERNEL_VERSION="$K_SUBVER-$K_NAME-$OS-$K_BASE-$K_VERSION"
fi

(
	START_TIME=`date +%s`
	FUNC_DELETE_PLACEHOLDERS
	FUNC_BUILD_KERNEL
	FUNC_CLEAN_DTB
	FUNC_BUILD_RAMDISK
	if [ $ZIP == "yes" ]; then
	    FUNC_BUILD_FLASHABLES
	fi
	END_TIME=`date +%s`
	let "ELAPSED_TIME=$END_TIME-$START_TIME"
	echo "Total compile time is $ELAPSED_TIME seconds"
	echo ""
) 2>&1 | tee -a ./$MODEL-$OS-build.log

	echo "Your flasheable release can be found in the build folder"
	echo ""
}


#
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
echo "Only S7 EDGE G935"
echo "(1) S7 Edge - Samsung OREO"
echo "(2) S7 Edge - Samsung PIE (r29)"
echo "(3) S7 Edge - Samsung Q"
echo "(4) S7 Edge - Lineage 16"
echo "(5) S7 Edge - Lineage 17/18"
echo "(6) S7 Edge - TREBLE"
echo "(7) N7 FE - Samsung Q"
echo ""
echo "S7 AllInOne: OREO + PIE + Lineage + Treble"
echo "(8) S7 AllInOne: OREO + PIE + Q + AOSP + TREBLE"
echo ""
echo "**************************************"
echo ""
read -p "Select an option to compile the kernel " prompt
echo ""


if [[ $prompt == "1" ]]; then

    echo "S7 Edge - Samsung OREO Selected"

    OS=twOreo
    ANDROID=8
    MTP=sam
    GPU=r29
    MODEL=G935
    OS_DEFCONFIG=$DEFCONFIG_OREO
    DEVICE_DEFCONFIG=$DEFCONFIG_S7EDGE
    PERMISSIVE=yes
    ZIP=yes
    ZIP_NAME=$K_NAME-$OS-$MODEL-$K_BASE-$K_VERSION.zip
    MAIN
	
elif [[ $prompt == "2" ]]; then

    echo "S7 Edge - Samsung PIE Selected (r29)"

    OS=twPie
    ANDROID=9
    MTP=sam
    GPU=r29
    MODEL=G935
    OS_DEFCONFIG=$DEFCONFIG_PIE
    DEVICE_DEFCONFIG=$DEFCONFIG_S7EDGE
    PERMISSIVE=yes
    ZIP=yes
    ZIP_NAME=$K_NAME-$OS-$MODEL-$K_BASE-$K_VERSION.zip
    MAIN

elif [[ $prompt == "3" ]]; then

    echo "S7 Edge - Samsung Q Selected"

    OS=twQ
    ANDROID=9
    MTP=sam
    GPU=r29
    MODEL=G935
    OS_DEFCONFIG=$DEFCONFIG_PIE
    DEVICE_DEFCONFIG=$DEFCONFIG_S7EDGE
    PERMISSIVE=yes
    ZIP=yes
    ZIP_NAME=$K_NAME-$OS-$MODEL-$K_BASE-$K_VERSION.zip
    MAIN
	
elif [[ $prompt == "4" ]]; then

    echo "S7 Edge - Lineage 16 Selected"

    OS=los16
    ANDROID=8
    MTP=aosp
    GPU=r29
    MODEL=G935
    OS_DEFCONFIG=$DEFCONFIG_OREO
    DEVICE_DEFCONFIG=$DEFCONFIG_S7EDGE
    PERMISSIVE=yes
    ZIP=yes
    ZIP_NAME=$K_NAME-$OS-$MODEL-$K_BASE-$K_VERSION.zip
    MAIN

elif [[ $prompt == "5" ]]; then

    echo "S7 Edge - Lineage 17 Selected"

    OS=los18
    ANDROID=9
    MTP=aosp
    GPU=r29
    MODEL=G935
    OS_DEFCONFIG=$DEFCONFIG_PIE
    DEVICE_DEFCONFIG=$DEFCONFIG_S7EDGE
    PERMISSIVE=yes
    ZIP=yes
    ZIP_NAME=$K_NAME-$OS-$MODEL-$K_BASE-$K_VERSION.zip
    MAIN
    
elif [[ $prompt == "6" ]]; then

    echo "S7 Edge - TREBLE AOSP Selected"

    OS=treble
    ANDROID=9
    MTP=aosp
    GPU=r29
    MODEL=G935
    OS_DEFCONFIG=$DEFCONFIG_PIE
    DEVICE_DEFCONFIG=$DEFCONFIG_S7EDGE
    PERMISSIVE=yes
    ZIP=yes
    ZIP_NAME=$K_NAME-$OS-$MODEL-$K_BASE-$K_VERSION.zip
    MAIN

elif [[ $prompt == "7" ]]; then

    echo "N7 FE - Samsung Q Selected"

    OS=twQ
    ANDROID=9
    MTP=sam
    GPU=r29
    MODEL=N935
    OS_DEFCONFIG=$DEFCONFIG_PIE
    DEVICE_DEFCONFIG=$DEFCONFIG_N7FE
    PERMISSIVE=yes
    ZIP=yes
    ZIP_NAME=$K_NAME-$OS-$MODEL-$K_BASE-$K_VERSION.zip
    MAIN
    
elif [[ $prompt == "8" ]]; then

    echo "S7 AllInOne: OREO + PIE + AOSP"

    OS=twOreo
    ANDROID=8
    MTP=sam
    GPU=r29
    MODEL=G935
    OS_DEFCONFIG=$DEFCONFIG_OREO
    DEVICE_DEFCONFIG=$DEFCONFIG_S7EDGE
    PERMISSIVE=yes
    ZIP=no
    MAIN

    OS=twOreo
    ANDROID=8
    MTP=sam
    GPU=r29
    MODEL=G930
    OS_DEFCONFIG=$DEFCONFIG_OREO
    DEVICE_DEFCONFIG=$DEFCONFIG_S7FLAT
    PERMISSIVE=yes
    ZIP=no
    MAIN

    OS=twPie
    ANDROID=9
    MTP=sam
    GPU=r29
    MODEL=G935
    OS_DEFCONFIG=$DEFCONFIG_PIE
    DEVICE_DEFCONFIG=$DEFCONFIG_S7EDGE
    PERMISSIVE=yes
    ZIP=no
    MAIN

    OS=twPie
    ANDROID=9
    MTP=sam
    GPU=r29
    MODEL=G930
    OS_DEFCONFIG=$DEFCONFIG_PIE
    DEVICE_DEFCONFIG=$DEFCONFIG_S7FLAT
    PERMISSIVE=yes
    ZIP=no
    MAIN
    
    OS=twQ
    ANDROID=9
    MTP=sam
    GPU=r29
    MODEL=G935
    OS_DEFCONFIG=$DEFCONFIG_PIE
    DEVICE_DEFCONFIG=$DEFCONFIG_S7EDGE
    PERMISSIVE=yes
    ZIP=no
    MAIN

    OS=twQ
    ANDROID=9
    MTP=sam
    GPU=r29
    MODEL=G930
    OS_DEFCONFIG=$DEFCONFIG_PIE
    DEVICE_DEFCONFIG=$DEFCONFIG_S7FLAT
    PERMISSIVE=yes
    ZIP=no
    MAIN

    OS=los16
    ANDROID=8
    MTP=aosp
    GPU=r29
    MODEL=G935
    OS_DEFCONFIG=$DEFCONFIG_OREO
    DEVICE_DEFCONFIG=$DEFCONFIG_S7EDGE
    PERMISSIVE=yes
    ZIP=no
    MAIN

    OS=los16
    ANDROID=8
    MTP=aosp
    GPU=r29
    MODEL=G930
    OS_DEFCONFIG=$DEFCONFIG_OREO
    DEVICE_DEFCONFIG=$DEFCONFIG_S7FLAT
    PERMISSIVE=yes
    ZIP=no
    MAIN

    OS=los18
    ANDROID=9
    MTP=aosp
    GPU=r29
    MODEL=G935
    OS_DEFCONFIG=$DEFCONFIG_PIE
    DEVICE_DEFCONFIG=$DEFCONFIG_S7EDGE
    PERMISSIVE=yes
    ZIP=no
    MAIN

    OS=los18
    ANDROID=9
    MTP=aosp
    GPU=r29
    MODEL=G930
    OS_DEFCONFIG=$DEFCONFIG_PIE
    DEVICE_DEFCONFIG=$DEFCONFIG_S7FLAT
    PERMISSIVE=yes
    ZIP=no
    MAIN
    
    OS=treble
    ANDROID=9
    MTP=aosp
    GPU=r29
    MODEL=G935
    OS_DEFCONFIG=$DEFCONFIG_PIE
    DEVICE_DEFCONFIG=$DEFCONFIG_S7EDGE
    PERMISSIVE=yes
    ZIP=no
    MAIN
    
    OS=treble
    ANDROID=9
    MTP=aosp
    GPU=r29
    MODEL=G930
    OS_DEFCONFIG=$DEFCONFIG_PIE
    DEVICE_DEFCONFIG=$DEFCONFIG_S7FLAT
    PERMISSIVE=yes
    ZIP=no
    MAIN
    
    OS=twPie
    ANDROID=9
    MTP=sam
    GPU=r29
    MODEL=N935
    OS_DEFCONFIG=$DEFCONFIG_PIE
    DEVICE_DEFCONFIG=$DEFCONFIG_N7FE
    PERMISSIVE=yes
    ZIP=no
    MAIN
    
    OS=twQ
    ANDROID=9
    MTP=sam
    GPU=r29
    MODEL=N935
    OS_DEFCONFIG=$DEFCONFIG_PIE
    DEVICE_DEFCONFIG=$DEFCONFIG_N7FE
    PERMISSIVE=yes
    ZIP=yes
    ZIP_NAME=$K_NAME-AllInOne-$K_BASE-$K_VERSION.zip
    MAIN

fi

