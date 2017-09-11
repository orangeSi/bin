if [ "$1" == "" ];
then
	echo "sh $0 <one shell path>"
	exit
fi
i=$1
echo "#!/bin/bash">$i.tmp
echo "echo ==========start at : `date` ========== &&  ">>$i.tmp
cat $i|awk '{if($0!~"^#"){print $0" &&"}}' >>$i.tmp
#sed -ri 's/$/ \&\&/g' $i
echo "echo ==========start at : `date` ========== &&  ">>$i.tmp
echo "echo Still_waters_run_deep 1>&2 &&  " >>$i.tmp
echo "echo Still_waters_run_deep >$i.sign " >>$i.tmp
mv $i.tmp $i
