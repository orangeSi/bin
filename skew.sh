if [ "$2" == "" ];
then
	echo "sh $0 <ass.list> <Result/Separate>"
	exit
fi

cat $1|while read line;
do
	sample=`echo $line|awk '{print $1}'`
	ass=`echo $line|awk '{print $2}'`
	gene=`ls $2/$sample/3.Genome_Component/Gene_Prediction/$sample.glimmer.gff`
	cog=`ls $2/$sample/4.Genome_Function/General_Gene_Annotation/$sample.cog.list.anno.xls`
	rRNA=`ls $2/$sample/3.Genome_Component/ncRNA_Finding/*denovo.rRNA.gff`
	tRNA=`ls $2/$sample/3.Genome_Component/ncRNA_Finding/*tRNA.gff`
	sRNA=`ls $2/$sample/3.Genome_Component/ncRNA_Finding/*sRNA.cmsearch.confident.nr.gff`
	echo perl /ifshk4/BC_PUB/biosoft/pipe/bc_mg/BAC_Denovo/PGAP_3.0/07.GC-skew/v3/GC_skew_v3.pl -f $ass -c $cog -g $gene -o $sample -s $sRNA -r $rRNA -t $tRNA 
	perl /ifshk4/BC_PUB/biosoft/pipe/bc_mg/BAC_Denovo/PGAP_3.0/07.GC-skew/v3/GC_skew_v3.pl -f $ass -c $cog -g $gene -o $sample -s $sRNA -r $rRNA -t $tRNA &&	echo $samle done

done
