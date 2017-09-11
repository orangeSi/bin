if [ "$2" == "" ];
then
	echo "sh $0 <add/rm> <project_name>"
	exit
fi


time=50
sleep=3000
base=/ifshk7/BC_PS/sikaiwei/bin/
monitor=/ifshk4/BC_PUB/biosoft/PIPE_RD/Package/pymonitor/monitor

if [ "$1" == "add" ];
then
	echo "$2" >>$base/.project
	cat $base/.project|while read line;
	do
		echo $line|awk -v i=$2 '{if($1==i){print "already have ",i}}'
	done
	cat $base/.project|sort -u >$base/.project.tmp
	mv $base/.project.tmp $base/.project

elif [ "$1" = "rm" ];
then
	rm $base/.project.tmp
	cat $base/.project|while read line;
	do
		awk -v i=$2 '{if($1!=i){print $1}}'>>$base/.project.tmp
	done
	mv $base/.project.tmp $base/.project
else
	echo "only add or rm $base"
	exit
fi

if [ ! -f "$base/.project.lock" ];
then
	touch $base/.project.lock 
	for  i in $(seq 1 1 $time)
	do
		cat $base/.project|while read line;
		do
			sleep $sleep && $monitor updateproject -p $line && echo "$monitor updateproject -p $line done $i" >>$base/.project.stat
		done

	done
else
	echo have locked
fi

