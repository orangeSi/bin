#!/bin/sh

. /ifshk7/BC_PS/sikaiwei/software/EVidenceModeler-1.1.1/env.sh
## run EVM

g1=data/PTR-AA-01.Genemarkes.filter.gff
g2=data/PTR-AA-01.self.Augustus.filter.gff
genome=/ifshk5/BC_COM_P8/F15FTSHMHT0747/FUNrbjD/busco/falcon_unzip_2017/PTR-AA-01.genome.fa
evidence_modeler.pl --genome $genome \
                       --weights weights.txt \
		       --gene_predictions $g1 \
		       --gene_predictions $g2 \
                     > evm.out 

echo
echo
echo "*** Created EVM output file: evm.out ***"


## convert output to GFF3 format
for i in $(cat $g1 $g2|awk '{print $1}'|sort -u)
do
	EVM_to_GFF3.pl evm.out $i > evm.out.$i.gff3
done

echo
echo
echo "*** Converted EVM output to GFF3 format: evm.out.gff3 ***"

echo
echo "Done."




