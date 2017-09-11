for i in $(cat bms |awk -F '\t' '{print $3}')
do
	base=`ls ../*/*/*$i*_1.fq.gz|awk  '{print $0}'`
	lane1=`dirname $base`
	lane2=`basename $lane1`
	lib=`dirname  $lane1`
	lib=`basename  $lib`
	echo "$lib	$lane2"

done
