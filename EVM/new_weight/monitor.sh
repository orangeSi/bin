###  usage:sh monitor.sh <jobid>
if [ "$3" = "" ]; then
	echo "
	sh monitor.sh <jobid of sge> <limit of memory> <disk limit>
	usage:sh monitor.sh 12345 40 4000 
	when memory > 40G or Available disk space < 4000G,will suspend the sge job 12345
		"
	exit
fi
len=1000000
id=$1
limit=$2
disk_limit=$3

log="*.sh.e$1"
stat=$(qstat|grep $id|awk '{print $5}')
echo "stat is $stat"

while [ "$stat" != "r" ]
do
	echo "not running" >>cputime
	sleep 30
	stat=$(qstat|grep $id|awk '{print $5}')
done
echo "start run" >>cputime

for (( j=0; j<"$len"; j=j+1 ))
do
	sleep 33;
	echo >>cputime;
	date >>cputime;
	qstat -j $id >& tmp
	vmem=$(cat tmp|awk -F '=' ' /vmem=/ {print $5}'|awk -F '.' '{if($0~ /G/){print $1}else{print 0}}') ;
	exist=$(cat tmp|grep 'Following jobs do not exist'|wc -l);
	if [ $vmem -ge $limit ];
	then
		## suspend jobs
		qmod -sj $id ;
		echo "vmem is $vmem,>$limit;so i suspend the job"  >>cputime
		exit
	fi

	disk_left=$(perl -e 'my $disk=`df -h .|tail -1`;my @arr=split(/\s+/,$disk);$tmp=$arr[3];if($tmp=~ /(.*)T$/){print 1000*$1}elsif($tmp=~ /(.*)G$/){print $1}else{print 0}')
	if [ $disk_left -lt $disk_limit ];
	then
		qmod -sj $id 
		echo "disk_left is $disk_left;<$dis_limit,so suspend the job"
		echo "disk_left is $disk_left;<$dis_limit,so suspend the job">>cputime

		exit
	fi



	if [ $exist -ge 1 ];
	then
		echo "done" >>cputime
		exit
	fi
	# qmod -sj id ## suspend jobs
	# # qmod -usj id ## unsuspend       jobs
	#
	usage=$(cat tmp|grep 'usage');
	echo $usage >>cputime;
	date >>run.detail;
	echo $usage >>run.detail;
	tail -2 $log >>run.detail;
	date >>run.detail;
	echo >>run.detail;
	date >>cputime;
	echo >>cputime;
done


