#!/system/bin/sh

# Busybox 
if [ -e /su/xbin/busybox ]; then
	BB=/su/xbin/busybox;
else if [ -e /sbin/busybox ]; then
	BB=/sbin/busybox;
else
	BB=/system/xbin/busybox;
fi;
fi;

cat << CTAG
{
    name:I/O,
    elements:[
    	{ SPane:{
		title:"I/O Schedulers",
		description:{
			en:"Set the active I/O elevator algorithm. The I/O Scheduler decides how to prioritize and handle I/O requests. More info: <a href='http://timos.me/tm/wiki/ioscheduler'>Wiki</a>",
			es:"Establezca el I/O Scheduler activo. El I/O Scheduler decide cómo priorizar y manejar las peticiones de E/S. Más info: <a href='http://timos.me/tm/wiki/ioscheduler'>Wiki</a>"
		}
    	}},
	{ SSpacer:{
		height:1
	}},
	{ SOptionList:{
		title:{
			en:"Storage scheduler Internal",
			es:"Scheduler de memoria interna"
		},
		description:" ",
		default:$(cat /sys/block/sda/queue/scheduler | $BB awk 'NR>1{print $1}' RS=[ FS=]),
		action:"ioset scheduler",
		values:[
`
			for IOSCHED in \`cat /sys/block/sda/queue/scheduler | $BB sed -e 's/\]//;s/\[//'\`; do
				echo "\"$IOSCHED\",";
			done;
`
],
	}},
	{ SSpacer:{
		height:1
	}},
`
	if [ -f "/sys/block/mmcblk0/queue/scheduler" ]; then

		$BB echo '{ SOptionList:{
			title:{
				en:"Storage scheduler SD card",
				es:"Scheduler de SD externa"
			},
			description:" ",
			default:'$(cat /sys/block/mmcblk0/queue/scheduler | $BB awk 'NR>1{print $1}' RS=[ FS=]),
			$BB echo 'action:"ioset scheduler_ext",
			values:['

				for IOSCHED in \`cat /sys/block/mmcblk0/queue/scheduler | $BB sed -e 's/\]//;s/\[//'\`; do
					echo "\"$IOSCHED\",";
				done;

		$BB echo '],
			}},
	{ SSpacer:{
		height:1
	}},'

	fi
`
	{ SSeekBar:{
		title:{
			en:"Storage Read-Ahead Internal",
			es:"Cacheado memoria interna"
		},
		description:" ",
		max:4096,
		min:64,
		unit:" KB",
		step:64,
		default:$(cat /sys/block/sda/queue/read_ahead_kb),
		action:"ioset queue read_ahead_kb"
	}},
	{ SSpacer:{
		height:1
	}},
`
	if [ -f "/sys/block/mmcblk0/queue/read_ahead_kb" ]; then

		$BB echo '{ SSeekBar:{
			title:{
				en:"Storage Read-Ahead SD Card",
				es:"Cacheado SD externa"
			},
			description:" ",
			max:4096,
			min:64,
			unit:" KB",
			step:64,
			default:'$(cat /sys/block/mmcblk0/queue/read_ahead_kb),
			$BB echo 'action:"ioset queue_ext read_ahead_kb"
		}},
		{ SSpacer:{
			height:1
		}},'

	fi
`
	]
}
CTAG
