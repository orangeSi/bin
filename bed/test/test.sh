export PATH=/ifshk4/BC_PUB/biosoft/PIPE_RD/Package/bedtools2-2.25.0/bin:$PATH
#bedtools intersect -a A.bed -b B.be
bedtools intersect -a B.bed -b A.bed -wo -f 1
