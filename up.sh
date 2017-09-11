time=50
sleep=3000
project=F17FTSSCKF1555
monitor=/ifshk4/BC_PUB/biosoft/PIPE_RD/Package/pymonitor/monitor

for  i in $(seq 1 1 $time)
do
	sleep $sleep && $monitor updateproject -p $project 
	echo $i

done
