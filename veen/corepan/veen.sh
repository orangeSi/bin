if [ "$4" == "" ];
then
	echo "sh $0 <result dir of Core_Pan> <cov limit;30> <prefix of output> <keeped sample list,only keep less than 5 samples>"
	exit
fi
cd $1
dir=`dirname $0`
cp PanGene.matrix tmp.$3

if [ "$4" != "" ] ;
then
	perl $dir/filter.by.sample.pl $4 tmp.$3 out.$3 && mv out.$3 tmp.$3
fi

pan_num=`wc -l tmp.$3|awk '{print $1}'`
pan_num=$(($pan_num -1))
sed -ir 's/\s*$//g' tmp.$3
#cat tmp |awk -v cov=30 '{if(($2>=cov){$2=0}if($3>=cov){$3=0}if($4>=cov){$4=0}if($5>=cov){$5=0}print $0}}' >PanGene.matrix.new
perl $dir/veen.pl tmp.$3 $2 $3 && 
col_num=`cat PanGene.matrix.$3|awk -F '\t' '{print NF}'|head -n1` && 

echo "
pan <- read.table(\"PanGene.matrix.$3\", header=FALSE, sep = \"\t\",row.names = 1,as.is=TRUE)
##reverse the pan
pan_new <- t(pan)
write.table(pan_new,file=\"PanGene.matrix.$3.reverse\",quote=FALSE,sep=\"\t\",col.names = TRUE,row.name=FALSE)
">veen.R

/ifshk4/BC_PUB/biosoft/PIPE_RD/Package/R-3.1.1/bin/Rscript veen.R  && 
cat PanGene.matrix.$3.reverse |awk -v OFS="\t" -v num=$pan_num '$1=$1"\t"num' >tmp.$3 &&
cat tmp.$3|sed -r 's/Group\t\S*/Group\tnumOtus/' |sed  's/^/0\.3\t/' >part.$3 && 
sed -ir 's/^0.3\tGroup/label\tGroup/' part.$3 && 
rm tmp.$3 tmp.$3\r PanGene.matrix.$3 part.$3\r &&
mv part.$3 PanGene.matrix.veen.$3 && 
echo "file for veen:$1/PanGene.matrix.veen.$3,$1/out.$3.Mapping.txt,$1/out.$3.name.list"


