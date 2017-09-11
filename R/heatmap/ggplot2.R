#options(expressions=10000);
#t<-as.matrix(read.table('/ifshk5/BC_COM_P8/F16FTSEUHT0555/STRzlwD/SM10/xbio/Result/Process/ComparativeGenomics/Core_Pan/Core_Pan_1/Result/Dispensable.matrix', head =T));
#library(gplots);
#pdf('/ifshk5/BC_COM_P8/F16FTSEUHT0555/STRzlwD/SM10/xbio/Result/Process/ComparativeGenomics/Core_Pan/Core_Pan_1/Result/Dispensable_heatmap.pdf',);
#png('/ifshk5/BC_COM_P8/F16FTSEUHT0555/STRzlwD/SM10/xbio/Result/Process/ComparativeGenomics/Core_Pan/Core_Pan_1/Result/Dispensable_heatmap.png',);
#heatmap.2(t,col=redgreen(75),trace='none',cexCol=1,scale='none',labRow=NA,density.info='none',lmat=rbind( c(4,3,0),c(2,1,0),c(0,0,0) ), lwid=c(2,5,0), lhei=c(2,4,0.5))



library(ggplot2)
library(pheatmap)
data<-as.matrix(read.table('/ifshk5/BC_COM_P8/F16FTSEUHT0555/STRzlwD/SM10/xbio/Result/Process/ComparativeGenomics/Core_Pan/Core_Pan_1/Result/Dispensable.matrix', head =T));
png("/ifshk5/BC_COM_P8/F16FTSEUHT0555/STRzlwD/SM10/xbio/Result/Process/ComparativeGenomics/Core_Pan/Core_Pan_1/Result/Dispensable_heatmap.png")
#pheatmap(data,fontsize=4, fontsize_row=2, fontsize_col=5, cellwidth = 5, cellheight = 2) #最简单地直接出图
#pheatmap(data) #最简单地直接出图
pheatmap(data,show_rownames=0)
dev.off()

