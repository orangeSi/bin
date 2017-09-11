sub=/ifs4/BC_COM_P0/F12HPCNCKJ0179/TAKbyaD/F12HPCNCKJ0179_PLAqofD/00.data/PacBio/filter/data/filtered_subreads.fasta.gz
sr=$PWD/out
mkdir shell
for sub in $(ls $PWD/outdir/split.*.fa.gz)
do
    out=$sub.corrected.fa
    base=`basename $sub`
    echo "
. /ifshk7/BC_PS/sikaiwei/assembly/LoRDEC/LoRDEC-0.6/path.sh
lordec-correct -T 5  -i $sub -2 $sr -k 19 -o $out -s 3  && 
echo Still_waters_run_deep 1>&2 &&
echo Still_waters_run_deep >$PWD/shell/$base.cor.sh.sign" >$PWD/shell/$base.cor.sh
done



