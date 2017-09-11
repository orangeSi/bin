## list is list of reasd
for i in $(cat list)
do
	echo "perl /ifshk7/BC_PS/sikaiwei/bin/changeid.pl $i $i.new.gz && cp $i.new.gz $i && rm $i.new.gz && echo $i done"

done
