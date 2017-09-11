library(scales)

data<-read.table("PanGene.matrix",header = T)
result<-c(1:(ncol(data)+1))
	names(result)<-c(colnames(data),'corepan')
jiaoji<-which(data[,1]>30)
	for(x in 1:ncol(data)){
		kk<-which(data[,x]>30)
			binji<-c()
			jiaoji<- intersect(jiaoji,kk)
			for (j in (1:ncol(data))[-x] ){
				k<-which(data[,j]>30)
					union(k,binji)->binji
			}
		length(setdiff(kk,binji))->result[x]

	}

result['corepan']<-length(jiaoji)

flower<-function (result){
		n<-length(result)
			col<- rainbow(n) 
			q<-seq(0,2*pi,0.01)
			x<-cos(q)
			y<-0.5*sin(q)
			plot(0,0,type="n",xlim = c(-3,3),ylim=c(-3,3),axes = FALSE,xlab = "",ylab = "",xpd=TRUE)
			for(z in 0:(n-2)){
				r<-z/(n-1)*2*pi
					x1<-(x+1.5)*cos(r)+y*sin(r)
					y1<-y*cos(r)-(x+1.5)*sin(r)
					textx1<-2.5*cos(r)
					texty1<- -2.5*sin(r)
					textx2<-1.5*cos(r)
					texty2<- -1.5*sin(r)
#points(x1,y1,type="l")
					polygon(x1,y1,col =alpha(col[z+1],0.5))
					#text(textx1,texty1,names(result)[z+1])
					text(textx2,texty2,result[z+1])
					polygon(0.7*sin(q),0.7*cos(q),col="white")
					text(0,0,result[n])
			}}



pdf("flower.no.name.pdf")
flower(result)
dev.off()
