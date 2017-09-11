genomesize=5000000
cov=40
base=$(($genomesize * $cov))
/ifshk7/BC_PS/sikaiwei/bin/kmer/kmerfreq -k 17 -c 0.9 -m 0  -b $base -t 3 -p PLAqofD fq.lst
