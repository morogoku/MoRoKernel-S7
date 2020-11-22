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

get_sel2()
{
  sel_file=$DIR_SEL/$1
  sel_option=$2
  sel_value=`cat $sel_file | grep $sel_option | cut -d '=' -f2`
  echo $sel_value
}


# Set fp_always_on
if [ ! -e $DIR_SEL/menu.prop ]; then
	fp_always_on="fp_always_on=0"
else
	val1=`get_sel2 menu.prop chk16`
        case $val1 in
        	0)
        	  fp_always_on="fp_always_on=0"
        	  ;;
        	1)
        	  fp_always_on="fp_always_on=1"
        	  ;;
        esac
fi


# Set kernel new command line
cd /tmp/moro/aik/split_img
/sbin/busybox sed -i "s/fp_always_on=0/$fp_always_on/" boot.img-zImage

