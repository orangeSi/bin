base=../../step3/outdir/Result/Separate
for i in $(ls $base)
do
	  rsync -ar  $base/$i/3.Genome_Component $i/

done
