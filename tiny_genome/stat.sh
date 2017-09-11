for i in $(ls */2*/*final.fa)
do
	scf=$i
	dir=`dirname $i`
	sample=`basename $i|sed 's/.final.fa//'`
	perl /ifshk4/BC_PUB/biosoft/pipe/bc_mg/BAC_Denovo/BAC_pipeline_1.1.1/Assembly/Assembly_V2.4/lib/SOAP2/WGS_uplod_Seq.pl $scf -scaftig $dir/$sample.contig -scafl 0 >$dir/$sample.seq 2> $dir/$sample.agp 
	perl /ifshk4/BC_PUB/biosoft/pipe/bc_mg/BAC_Denovo/BAC_pipeline_1.1.1/bin/../Assembly/Assembly_V2.4/lib/comm_bin/assembly_stat.2.pl $dir/$sample.seq  >$dir/$sample.assembly.stat

done
