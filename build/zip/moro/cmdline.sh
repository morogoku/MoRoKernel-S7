#!/sbin/sh
#
# cmdline script from Apollo kernel (by lyapota)
#
# MoRoKernel script
#
#

DIR_SEL=/tmp/aroma

get_sel()
{
  sel_file=$DIR_SEL/$1
  sel_value=`cat $sel_file | cut -d '=' -f2`
  echo $sel_value
}


# Set little_ms

if [ ! -e $DIR_SEL/loc.prop ]; then
	little_ms="little_ms=4"
else
	val1=`get_sel loc.prop`
        case $val1 in
        	1)
        	  little_ms="little_ms=3"
        	  ;;
        	2)
        	  little_ms="little_ms=2"
        	  ;;
        	3)
        	  little_ms="little_ms=1"
        	  ;;
        esac
fi


# Set kernel new command line
cd /tmp/moro/aik/split_img
/sbin/busybox sed -i "s/little_ms=4/$little_ms/" boot.img-zImage

