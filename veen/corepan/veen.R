pan <- read.table("PanGene.matrix.new", header=FALSE, sep = "\t",row.names = 1,as.is=TRUE)
##reverse the pan
pan_new <- t(pan)
write.table(pan_new,file="PanGene.matrix.reverse",quote=FALSE,sep="\t",col.names = TRUE,row.name=FALSE)
