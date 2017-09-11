if [ "$3" == "" ];
then
	echo "sh $0 <*sh> <0.5G> <THEpotR>"
	exit
fi

code=$3
queue=bc.q
mem=$2
raw=$PWD
for i in $(ls $1)
do
    dir=`dirname $i`
    cd $raw
    cd $dir
    base=`basename $i`
    if [ ! -f "$base.sign" ];
    then
        dir=`dirname $i`
        shell=`basename $i`
        qsub -cwd -P $code -q $queue -l vf=$mem $shell && echo $i 
        #$echo not $i
    fi

done
