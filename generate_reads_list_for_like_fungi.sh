if [ "$3" == "" ];
then
	echo "sh $0 <Result/Separate> <insert size> <reads length>"
	exit
fi
base=$1
insert=$2
read_length=$3
for  i in $(ls -F $base/|grep '/'|sed 's/\/$//')
do
	r1=`ls $base/$i/1*/*1.fq.gz`
	r2=`ls $base/$i/1*/*2.fq.gz`
	echo "$i	Short1	$insert	$r1,$r2	$read_length:$read_length"
done






