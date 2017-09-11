#/bin/bash


if [ $# -ne 1 ]

then
echo "Usage:rotate urfile"
exit 1
fi

if [ ! -s $1 ]
then 
echo "Usage:rotate urfile"
exit 1
fi

row=$(sed -n '$=' $1)
col=$(awk 'NR==1{print NF}' $1)
awk -v row=$row -v col=$col -F '\t' '{ for(i=1;i<=NF;i++)a[NR"-"i]=$i }END{ for(i=1;i<=col;i++){ for(j=1;j<=row;j++) printf("%s\t",a[j"-"i]);print ""} }' $1
