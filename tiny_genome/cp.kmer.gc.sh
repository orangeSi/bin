base=../../02.Assembly/kmer_gc/outdir/Result/Separate/
for i in $(ls $base)
do
	 cp $base/$i/2.Assembly/*kmer* $base/$i/2.Assembly/*.GC-depth.png $i/2.Assembly

done
