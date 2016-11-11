#!/system/bin/sh

BB=/system/xbin/busybox;

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
		values:[`while read values; do $BB printf "%s, \n" $values | $BB tr -d '[]'; done < /sys/block/sda/queue/scheduler`],
	}},
	{ SSpacer:{
		height:1
	}},
	{ SOptionList:{
		title:{
			en:"Storage scheduler SD card",
			es:"Scheduler de SD externa"
		},
		description:" ",
		default:$(cat /sys/block/mmcblk0/queue/scheduler | $BB awk 'NR>1{print $1}' RS=[ FS=]),
		action:"ioset scheduler_ext",
		values:[`while read values; do $BB printf "%s, \n" $values | $BB tr -d '[]'; done < /sys/block/mmcblk0/queue/scheduler`],
	}},
	{ SSpacer:{
		height:1
	}},
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
	{ SSeekBar:{
		title:{
			en:"Storage Read-Ahead SD Card",
			es:"Cacheado SD externa"
		},
		description:" ",
		max:4096,
		min:64,
		unit:" KB",
		step:64,
		default:$(cat /sys/block/mmcblk0/queue/read_ahead_kb),
		action:"ioset queue_ext read_ahead_kb"
	}},
	{ SSpacer:{
		height:1
	}},
	]
}
CTAG
