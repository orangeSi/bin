tail -6  ../../02.Assembly/Final/final.list|while read line;
do
	sample=`echo $line|awk '{print $1}'`
	ass=`echo $line|awk '{print $2}'`
	mkdir $sample/2.Assembly
	cp $ass $sample/2.Assembly
done
