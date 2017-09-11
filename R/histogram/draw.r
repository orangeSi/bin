#Plot Clean Polymerase Reads and Clean Subreads Length/Quality distritution
library(ggplot2)
library(grid)
#d<-read.table('/ifshk5/BC_COM_P3/F16FTSEUHT0555/HUMfzyD/work/F16FTSEUHT0555_HUMfzyD_new/Process/FilterData/FW57/Filter_Pacbio/FW57.filtered_PolymeraseReads.length.quality.data',header = T, sep='\t')
#A=ggplot(d)+labs(title='PolymeraseReads Length distribution \n(FW57)\n', x='PolymeraseReads Length(bp)', y='Number of Reads(#)')+
#geom_histogram(aes(x=length),binwidth = 1000,fill="blue",col="black")+
#theme(legend.position="none", plot.title=element_text(face='bold'), axis.text=element_text(color='black',size=12))

#B=ggplot(d)+labs(title='PolymeraseReads Quality distribution \n(FW57)\n', x='PolymeraseReads Quality(#)', y='Number of Reads(#)')+
#geom_histogram(aes(x=quality),binwidth = 0.001,fill="green",col="black")+
#theme(legend.position="none", plot.title=element_text(face='bold'), axis.text=element_text(color='black',size=12))

pdf("Pacbio.Cleandata.pdf", width = 10, height = 8)
d<-read.table('2cell.fasta.len',header = T, sep="\t")
A<-ggplot(d)+labs(title='Subreads Length distribution \n(Amanita.subjunquillea.H-1)\n', x='Subreads Length(bp)', y='Number of Reads(#)')+
geom_histogram(aes(x=length),binwidth = 1000,fill="blue",col="black")
#theme(legend.position="none", plot.title=element_text(face='bold'), axis.text=element_text(color='black',size=12))
A

#grid.newpage()


dev.off()
