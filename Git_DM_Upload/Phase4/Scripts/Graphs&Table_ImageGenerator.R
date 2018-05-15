
library(ggplot2)
library(gridExtra)
i = 0
model="nn"
ModelCaps="Neural Network"
while (i<40)
{
  i=i+1;
  

files = paste0("E:\\Studies\\MCS ASU\\Spring 18\\CSE 572 DM\\Assignment 4\\nn_all.csv",sep = "");
#files = "E:\\Studies\\MCS ASU\\Spring 18\\CSE 572 DM\\Assignment 4\\DT_all.csv";
if (file.exists(files))
{print(paste("Reading ", i));
cd1 <- read.csv(files);
cd1<-data.frame(cd1, stringsAsFactors = FALSE);
#cd1 <-round(cd1,2); 
if(nrow(cd1)>0)
{cd1[,-5] <-round(cd1[,-5],2); 
print(cd1);
#img = paste(model,"_",i,".png",sep = "");
img = "nn_all_table.png";
library(gridExtra)
png(img, height = 300, width = 400)
grid.table(cd1)
dev.off()
cd1$Classes[cd1$Class=="1"]="Class 01"
cd1$Classes[cd1$Class=="2"]="Class 02"
cd1$Classes[cd1$Class=="3"]="Class 03"
cd1$Classes[cd1$Class=="4"]="Class 04"
cd1$Classes[cd1$Class=="5"]="Class 05"
cd1$Classes[cd1$Class=="6"]="Class 06"
cd1$Classes[cd1$Class=="7"]="Class 07"
cd1$Classes[cd1$Class=="8"]="Class 08"
cd1$Classes[cd1$Class=="9"]="Class 09"
cd1$Classes[cd1$Class=="10"]="Class 10"
img = "nn_all.png";
library(ggrepel) 
#plot
set.seed(42) 
ggplot(cd1) +theme(
  panel.background = element_rect(fill = "aliceblue",
                                  colour = "aliceblue",
                                  size = 0.5, linetype = "solid"),
  panel.grid.major = element_line(size = 0.5, linetype = 'solid',
                                  colour = "white"), 
  panel.grid.minor = element_line(size = 0.25, linetype = 'solid',
                                  colour = "white")
)+
  geom_point(aes(Precision, Recall), size = cd1$F1.Score*50, color = 'grey') + xlim(0, max(cd1$Precision)+0.1)+ylim(0, max(cd1$Recall)+0.1)+
  geom_label_repel( aes(Precision, Recall, fill = Classes, 
                        label = Accuracy), 
                    fontface = 'bold', 
                    color = 'white', 
                    
                    box.padding = unit(0.35, "lines"), 
                    point.padding = unit(0.5, "lines") )  + labs(
#title=paste(ModelCaps,"User", i ,"Metrics"),
title=paste(ModelCaps,"Combined Metrics"),                      
subtitle="[X Axis: Precision, Y Axis: Recall, Color: Classes, Size: F1 Values, Labels: Accuracy]")
# = paste("svm_scatter_",i,".png",sep = "")
ggsave(img, width = 18, height = 18, units = "cm")
}
}
}


#plotting without using ggplot2
attach(cd1)
img = paste(model,"_scatter_",i,".png",sep = "")
library(gridExtra)
png(img, height = 800, width = 800)
plot(jitter(Precision),jitter(Recall),xlab="Precision", ylab="Recall", xlim = c(0, max(Precision)+0.2),ylim = c(0, max(Recall)+0.2), pch=19, col=Colour, cex=F1*30,main=paste("User",i,"Decision Tree Metrics"),sub="[X Axis: Precision, Y Axis: Recall, Color: Classes, Size: F1 Values, Labels: Accuracy]",cex.main=1.5,cex.lab=1.5)
grid(10, 10, col = "lightgray", lty = "solid",
     lwd = par("lwd"), equilogs = TRUE)
text (Precision, Recall, Accuracy)

legend("topright", inset=0.01,
       legend=paste("Class",cd1$Class), fill=Colour, horiz=FALSE,pt.cex = 1,cex=1.1)
dev.off()

