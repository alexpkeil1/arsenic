######################################################################################################################
# Author: Alex Keil
# Program: mtcs_gformula_kmpics_2014926.R
# Language: R
# Date: Friday, September 26, 2014 at 5:11:06 PM
# Project: 
# Tasks:
# Data in: 
# Data out: 
# Description:
# Keywords:
# Released under the GNU General Public License: http://www.gnu.org/copyleft/gpl.html
######################################################################################################################
library(ggplot2)
library(haven)
ls <- system("ls /Users/akeil/EpiProjects/MT_copper_smelters/data/mcdata/ | grep ci", intern=TRUE)
ls2 <- system("ls /Users/akeil/EpiProjects/MT_copper_smelters/data/mcdata/ | grep surv", intern=TRUE)

suff = "_30k"

for(i in 1:length(ls)){
 nm <- (gsub("surv_","",gsub(".sas7bdat","",ls[i])))
  #assign(nm, read.sas7bdat(paste0("/Users/akeil/EpiProjects/MT_copper_smelters/data/mcdata/", ls[i])))
  assign(nm, read_sas(paste0("/Users/akeil/EpiProjects/MT_copper_smelters/data/mcdata/", ls[i])))
  assign(nm, within(eval(as.name(nm)), time <- eval(as.name(gsub("surv_","",gsub(".sas7bdat","",ls[i]))))[,1]))
  if(length(grep("date",nm))) assign(nm, within(eval(as.name(nm)), time <- as.Date(eval(as.name(gsub("surv_","",gsub(".sas7bdat","",ls[i]))))[,1], origin="1960-01-01")))
}

for(i in 1:length(ls2)){
  nm <- (gsub("surv_","",gsub(".sas7bdat","",ls2[i])))
  #assign(nm, read.sas7bdat(paste0("/Users/akeil/EpiProjects/MT_copper_smelters/data/mcdata/", ls2[i])))
  assign(nm, read_sas(paste0("/Users/akeil/EpiProjects/MT_copper_smelters/data/mcdata/", ls2[i])))
  assign(nm, within(eval(as.name(nm)), time <- eval(as.name(gsub("surv_","",gsub(".sas7bdat","",ls2[i]))))[,1]))
  if(length(grep("date",nm))) assign(nm, within(eval(as.name(nm)), time <- as.Date(eval(as.name(gsub("surv_","",gsub(".sas7bdat","",ls2[i]))))[,1], origin="1960-01-01")))
}


#cumulative incidence
pubplotd = "/Users/akeil/Documents/Papers/2014_gformula_as/manuscript/figures/"
theme_alex <- list(theme(panel.background=element_blank(),
   panel.grid.major.x=element_blank(), panel.grid.major.y=element_blank(), 
   panel.grid.minor.x=element_blank(),panel.grid.minor.y=element_blank(),
   axis.line = element_line(colour = "black"), 
   axis.text=element_text(colour="black", face="bold", size=14), 
   axis.title=element_text(size=16, face="bold")))
### plots for publication
#pdf(paste0(pubplotd, "fig2",".pdf"),  width=8/1.57, height=6/1.57)
p <-   ggplot(data=cidata_age_obs) + geom_line(aes(x=time, y=ci_ac, colour="All cause", linetype="Observed"), size=1.2) + 
    geom_line(aes(x=time, y=ci_rc, colour="Resp. cancer", linetype="Observed"), data=cidata_age_obs, size=1.2) + 
    geom_line(aes(x=time, y=ci_cv, colour="Heart dis.", linetype="Observed"), data=cidata_age_obs, size=1.2) + 
    geom_line(aes(x=time, y=ci_oc, colour="Other", linetype="Observed"), data=cidata_age_obs, size=1.2) + 
    geom_line(aes(x=time, y=ci_ac, colour="All cause", linetype="Natural course"), data=cidata_age_nc, size=1.2) + 
    geom_line(aes(x=time, y=ci_rc, colour="Resp. cancer", linetype="Natural course"), data=cidata_age_nc, size=1.2) + 
    geom_line(aes(x=time, y=ci_cv, colour="Heart dis.", linetype="Natural course"), data=cidata_age_nc, size=1.2) + 
    geom_line(aes(x=time, y=ci_oc, colour="Other", linetype="Natural course"), data=cidata_age_nc, size=1.2)
p + scale_x_continuous("Age") + scale_y_continuous("Cumulative incidence") +
   scale_colour_grey("Cause", breaks=c("All cause", "Other", "Heart dis.", "Resp. cancer"), labels=c("All cause", "Other", "Heart dis.", "Resp. cancer")) + scale_linetype_discrete("") + 
  theme_alex + theme(line=element_line(size=1.2), legend.position=c(0,1), 
  legend.justification=c(0,1))
#dev.off()

#pdf(paste0(pubplotd, "fig2revised",".pdf"),  width=8/1.57, height=6/1.57)
sz=0.6
p <-   ggplot(data=cidata_age_obs) + geom_line(aes(x=time, y=ci_ac, colour="All cause", linetype="Observed"), size=sz) + 
    geom_line(aes(x=time, y=ci_rc, colour="Resp. cancer", linetype="Observed"), data=cidata_age_obs, size=sz) + 
    geom_line(aes(x=time, y=ci_cv, colour="Heart disease", linetype="Observed"), data=cidata_age_obs, size=sz) + 
    geom_line(aes(x=time, y=ci_oc, colour="Other", linetype="Observed"), data=cidata_age_obs, size=sz) + 
    geom_line(aes(x=time, y=ci_ac, colour="All cause", linetype="Natural course"), data=cidata_age_nc, size=sz) + 
    geom_line(aes(x=time, y=ci_rc, colour="Resp. cancer", linetype="Natural course"), data=cidata_age_nc, size=sz) + 
    geom_line(aes(x=time, y=ci_cv, colour="Heart disease", linetype="Natural course"), data=cidata_age_nc, size=sz) + 
    geom_line(aes(x=time, y=ci_oc, colour="Other", linetype="Natural course"), data=cidata_age_nc, size=sz)
p + scale_x_continuous("Age") + scale_y_continuous("Cumulative incidence") +
   scale_colour_grey("Cause", breaks=c("All cause", "Other", "Heart disease", "Resp. cancer"), labels=c("All cause", "Other", "Heart disease", "Resp. cancer")) + scale_linetype_discrete("") + 
  theme_alex + theme(line=element_line(size=sz), legend.position=c(0,1), 
  legend.justification=c(0,1))
#dev.off()

pdf(paste0(pubplotd, "fig2revised2",".pdf"),  width=8/1.57, height=6/1.57)
sz=0.6
p <-   ggplot(data=cidata_age_obs) + geom_line(aes(x=time, y=ci_ac, colour="All cause", linetype="Observed"), size=sz) + 
    geom_line(aes(x=time, y=ci_rc, colour="Resp. cancer", linetype="Observed"), data=cidata_age_obs, size=sz) + 
    geom_line(aes(x=time, y=ci_cv, colour="Heart disease", linetype="Observed"), data=cidata_age_obs, size=sz) + 
    geom_line(aes(x=time, y=ci_oc, colour="Other", linetype="Observed"), data=cidata_age_obs, size=sz) + 
    geom_line(aes(x=time, y=ci_ac, colour="All cause", linetype="Natural course"), data=cidata_age_nc, size=sz) + 
    geom_line(aes(x=time, y=ci_rc, colour="Resp. cancer", linetype="Natural course"), data=cidata_age_nc, size=sz) + 
    geom_line(aes(x=time, y=ci_cv, colour="Heart disease", linetype="Natural course"), data=cidata_age_nc, size=sz) + 
    geom_line(aes(x=time, y=ci_oc, colour="Other", linetype="Natural course"), data=cidata_age_nc, size=sz)
p + scale_x_continuous("Age") + scale_y_continuous("Cumulative incidence") +
   scale_colour_grey("Cause", breaks=c("All cause", "Other", "Heart disease", "Resp. cancer"), labels=c("All cause", "Other", "Heart disease", "Resp. cancer")) + scale_linetype_discrete("") + 
  theme_alex + theme(line=element_line(size=sz), legend.position=c(0,1), 
  legend.justification=c(0,1))
dev.off()

#pdf(paste0(pubplotd, "fig3a",".pdf"),  width=8/1.57, height=6/1.57)
  ggplot(data=cidata_age_obs) + #geom_line(aes(x=time, y=ci_rc, colour="Observed")) + 
    geom_line(aes(x=time, y=ci_ac, colour="Natural course"), data=cidata_age_nc, size=1.2) + 
	  geom_line(aes(x=time, y=ci_ac, colour="High exposure"), data=cidata_age_hi, size=1.2)  + 
	  geom_line(aes(x=time, y=ci_ac, colour="No exposure"), data=cidata_age_ne, size=1.2)  +
	   scale_x_continuous("Age") + scale_y_continuous("Cumulative incidence") +
   scale_colour_grey("Intervention", breaks=c("High exposure", "Natural course", "No exposure"), labels=c("High exposure", "Natural course", "No exposure")) + 
  theme_alex + theme(line=element_line(size=1.2), legend.position=c(0,1), 
  legend.justification=c(0,1))
#dev.off()
  
boxdathi = read.csv("/Users/akeil/EpiProjects/MT_copper_smelters/data/out/all_withmid/cidat_all__hi_70.csv")
boxdatmed = read.csv("/Users/akeil/EpiProjects/MT_copper_smelters/data/out/all_withmid/cidat_all__med_70.csv")
boxdatnc = read.csv("/Users/akeil/EpiProjects/MT_copper_smelters/data/out/all_withmid/cidat_all__nc_70.csv")
boxdatlo = read.csv("/Users/akeil/EpiProjects/MT_copper_smelters/data/out/all_withmid/cidat_all__lo_70.csv")
boxdatne = read.csv("/Users/akeil/EpiProjects/MT_copper_smelters/data/out/all_withmid/cidat_all__ne_70.csv")
  
  
pdf(paste0(pubplotd, "fig3arev",".pdf"),  width=8/1.57, height=6/1.57)
sz = 0.4
  ggplot(data=cidata_age_obs) + #geom_line(aes(x=time, y=ci_rc, colour="Observed")) + 
    geom_line(aes(x=time, y=ci_ac, colour="Natural course", linetype="Natural course"), data=cidata_age_nc, size=sz) + 
	  geom_line(aes(x=time, y=ci_ac, colour="High exposure", linetype="High exposure"), data=cidata_age_hi, size=sz)  + 
	  geom_line(aes(x=time, y=ci_ac, colour="Med exposure", linetype="Med exposure"), data=cidata_age_med, size=sz)  +
	  geom_line(aes(x=time, y=ci_ac, colour="Low exposure", linetype="Low exposure"), data=cidata_age_lo, size=sz)  +
	  geom_line(aes(x=time, y=ci_ac, colour="No exposure", linetype="No exposure"), data=cidata_age_ne, size=sz)  +
    #geom_boxplot(aes(x=70, y=ci_ac, colour="High exposure"), data=boxdathi, outlier.size=0, fill = "white", position="identity", alpha=.5)  +
    #geom_boxplot(aes(x=70, y=ci_ac, colour="No exposure"), data=boxdatne, outlier.size=0, fill = "white", position="identity", alpha=.5)  +
	 scale_x_continuous("Age") + scale_y_continuous("Cumulative incidence") +
   scale_colour_discrete("Intervention", breaks=c("High exposure",  "Med exposure","Natural course","Low exposure", "No exposure"), labels=c("High exposure",  "Med exposure","Natural course","Low exposure", "No exposure")) + 
   scale_linetype_discrete("Intervention", breaks=c("High exposure",  "Med exposure","Natural course","Low exposure", "No exposure"), labels=c("High exposure",  "Med exposure","Natural course","Low exposure", "No exposure")) + 
  theme_alex + theme(line=element_line(size=sz), legend.position=c(0,1), 
  legend.justification=c(0,1))
dev.off()


#pdf(paste0(pubplotd, "fig3b",".pdf"),  width=8/1.57, height=6/1.57)
  ggplot(data=cidata_age_obs) + #geom_line(aes(x=time, y=ci_rc, colour="Observed")) + 
	  geom_line(aes(x=time, y=ci_rc, colour="Natural course"), data=cidata_age_nc, size=1.2) + 
	  geom_line(aes(x=time, y=ci_rc, colour="High exposure"), data=cidata_age_hi, size=1.2)  + 
	  geom_line(aes(x=time, y=ci_rc, colour="No exposure"), data=cidata_age_ne, size=1.2)  +
	   scale_x_continuous("Age") + scale_y_continuous("Cumulative incidence") +
   scale_colour_grey("Intervention", breaks=c("High exposure", "Natural course", "No exposure"), labels=c("High exposure", "Natural course", "No exposure")) + 
  theme_alex + theme(line=element_line(size=1.2), legend.position=c(0,1), 
  legend.justification=c(0,1))
#dev.off()

pdf(paste0(pubplotd, "fig3brev",".pdf"),  width=8/1.57, height=6/1.57)
sz = 0.4
  ggplot(data=cidata_age_obs) + #geom_line(aes(x=time, y=ci_rc, colour="Observed")) + 
    geom_line(aes(x=time, y=ci_rc, colour="Natural course", linetype="Natural course"), data=cidata_age_nc, size=sz) + 
	  geom_line(aes(x=time, y=ci_rc, colour="High exposure", linetype="High exposure"), data=cidata_age_hi, size=sz)  + 
	  geom_line(aes(x=time, y=ci_rc, colour="Med exposure", linetype="Med exposure"), data=cidata_age_med, size=sz)  +
	  geom_line(aes(x=time, y=ci_rc, colour="Low exposure", linetype="Low exposure"), data=cidata_age_lo, size=sz)  +
	  geom_line(aes(x=time, y=ci_rc, colour="No exposure", linetype="No exposure"), data=cidata_age_ne, size=sz)  +
    #geom_boxplot(aes(x=70, y=ci_rc, colour="High exposure"), data=boxdathi, outlier.size=0, fill = "white", position="identity", alpha=.5)  +
    #geom_boxplot(aes(x=70, y=ci_rc, colour="No exposure"), data=boxdatne, outlier.size=0, fill = "white", position="identity", alpha=.5)  +
	 scale_x_continuous("Age") + scale_y_continuous("Cumulative incidence") +
   scale_colour_discrete("Intervention", breaks=c("High exposure",  "Med exposure","Natural course","Low exposure", "No exposure"), labels=c("High exposure",  "Med exposure","Natural course","Low exposure", "No exposure")) + 
   scale_linetype_discrete("Intervention", breaks=c("High exposure",  "Med exposure","Natural course","Low exposure", "No exposure"), labels=c("High exposure",  "Med exposure","Natural course","Low exposure", "No exposure")) + 
  theme_alex + theme(line=element_line(size=sz), legend.position=c(0,1), 
  legend.justification=c(0,1))
dev.off()

#pdf(paste0(pubplotd, "fig3c",".pdf"),  width=8/1.57, height=6/1.57)
	ggplot(data=cidata_age_obs) + #geom_line(aes(x=time, y=ci_cv, colour="Observed")) + 
	  geom_line(aes(x=time, y=ci_cv, colour="Natural course"), data=cidata_age_nc, size=1.2) + 
	  geom_line(aes(x=time, y=ci_cv, colour="High exposure"), data=cidata_age_hi, size=1.2)  + 
    geom_line(aes(x=time, y=ci_cv, colour="No exposure"), data=cidata_age_ne, size=1.2)  +
     scale_x_continuous("Age") + scale_y_continuous("Cumulative incidence") +
   scale_colour_grey("Intervention", breaks=c("High exposure", "Natural course", "No exposure"), labels=c("High exposure", "Natural course", "No exposure")) + 
  theme_alex + theme(line=element_line(size=1.2), legend.position=c(0,1), 
  legend.justification=c(0,1))
#dev.off()

pdf(paste0(pubplotd, "fig3crev",".pdf"),  width=8/1.57, height=6/1.57)
sz = 0.4
  ggplot(data=cidata_age_obs) + #geom_line(aes(x=time, y=ci_rc, colour="Observed")) + 
    geom_line(aes(x=time, y=ci_cv, colour="Natural course", linetype="Natural course"), data=cidata_age_nc, size=sz) + 
	  geom_line(aes(x=time, y=ci_cv, colour="High exposure", linetype="High exposure"), data=cidata_age_hi, size=sz)  + 
	  geom_line(aes(x=time, y=ci_cv, colour="Med exposure", linetype="Med exposure"), data=cidata_age_med, size=sz)  +
	  geom_line(aes(x=time, y=ci_cv, colour="Low exposure", linetype="Low exposure"), data=cidata_age_lo, size=sz)  +
	  geom_line(aes(x=time, y=ci_cv, colour="No exposure", linetype="No exposure"), data=cidata_age_ne, size=sz)  +
    #geom_boxplot(aes(x=70, y=ci_cv, colour="High exposure"), data=boxdathi, outlier.size=0, fill = "white", position="identity", alpha=.5)  +
    #geom_boxplot(aes(x=70, y=ci_cv, colour="No exposure"), data=boxdatne, outlier.size=0, fill = "white", position="identity", alpha=.5)  +
	 scale_x_continuous("Age") + scale_y_continuous("Cumulative incidence") +
   scale_colour_discrete("Intervention", breaks=c("High exposure",  "Med exposure","Natural course","Low exposure", "No exposure"), labels=c("High exposure",  "Med exposure","Natural course","Low exposure", "No exposure")) + 
   scale_linetype_discrete("Intervention", breaks=c("High exposure",  "Med exposure","Natural course","Low exposure", "No exposure"), labels=c("High exposure",  "Med exposure","Natural course","Low exposure", "No exposure")) + 
  theme_alex + theme(line=element_line(size=sz), legend.position=c(0,1), 
  legend.justification=c(0,1))
dev.off()

pdf(paste0(pubplotd, "fig3d",".pdf"),  width=8/1.57, height=6/1.57)
sz = 0.4
  ggplot(data=cidata_age_obs) + #geom_line(aes(x=time, y=ci_rc, colour="Observed")) + 
    geom_line(aes(x=time, y=ci_oc, colour="Natural course", linetype="Natural course"), data=cidata_age_nc, size=sz) + 
	  geom_line(aes(x=time, y=ci_oc, colour="High exposure", linetype="High exposure"), data=cidata_age_hi, size=sz)  + 
	  geom_line(aes(x=time, y=ci_oc, colour="Med exposure", linetype="Med exposure"), data=cidata_age_med, size=sz)  +
	  geom_line(aes(x=time, y=ci_oc, colour="Low exposure", linetype="Low exposure"), data=cidata_age_lo, size=sz)  +
	  geom_line(aes(x=time, y=ci_oc, colour="No exposure", linetype="No exposure"), data=cidata_age_ne, size=sz)  +
    #geom_boxplot(aes(x=70, y=ci_oc), data=boxdathi, outlier.size=0, fill = "white", position="identity", alpha=.5)  +
    #geom_boxplot(aes(x=70, y=ci_oc), data=boxdatne, outlier.size=0, fill = "white", position="identity", alpha=.5)  +
	   scale_x_continuous("Age") + scale_y_continuous("Cumulative incidence") +
   scale_colour_discrete("Intervention", breaks=c("High exposure",  "Med exposure","Natural course","Low exposure", "No exposure"), labels=c("High exposure",  "Med exposure","Natural course","Low exposure", "No exposure")) + 
   scale_linetype_discrete("Intervention", breaks=c("High exposure",  "Med exposure","Natural course","Low exposure", "No exposure"), labels=c("High exposure",  "Med exposure","Natural course","Low exposure", "No exposure")) + 
  theme_alex + theme(line=element_line(size=sz), legend.position=c(0,1), 
  legend.justification=c(0,1))
dev.off()

plotd = "~/EpiProjects/MT_copper_smelters/output/gformula_kmpics/"


#### all other plots
pdf(paste0(plotd, "gf_ints_obs_age",suff,".pdf"),  width=8/1.57, height=6/1.57)
  ggplot(data=cidata_age_obs) + geom_line(aes(x=time, y=ci_ac, colour="ac", linetype="Observed")) + 
    geom_line(aes(x=time, y=ci_rc, colour="rc", linetype="Observed"), data=cidata_age_obs) + 
    geom_line(aes(x=time, y=ci_cv, colour="cv", linetype="Observed"), data=cidata_age_obs) + 
    geom_line(aes(x=time, y=ci_oc, colour="oc", linetype="Observed"), data=cidata_age_obs) + 
    geom_line(aes(x=time, y=ci_ac, colour="ac", linetype="Nat. course"), data=cidata_age_nc) + 
    geom_line(aes(x=time, y=ci_rc, colour="rc", linetype="Nat. course"), data=cidata_age_nc) + 
    geom_line(aes(x=time, y=ci_cv, colour="cv", linetype="Nat. course"), data=cidata_age_nc) + 
    geom_line(aes(x=time, y=ci_oc, colour="oc", linetype="Nat. course"), data=cidata_age_nc)
dev.off()

pdf(paste0(plotd, "gf_ints_nc_age",suff,".pdf"),  width=8/1.57, height=6/1.57)
  ggplot(data=cidata_age_nc) + geom_line(aes(x=time, y=ci_ac, colour="All causes")) + 
    geom_line(aes(x=time, y=ci_rc, colour="Respiratory cancer"), data=cidata_age_nc) + 
    geom_line(aes(x=time, y=ci_cv, colour="Cardiovascular disease"), data=cidata_age_nc) + 
    geom_line(aes(x=time, y=ci_oc, colour="Other causes"), data=cidata_age_nc)
dev.off()



pdf(paste0(plotd, "gf_ints_allcause_age",suff,".pdf"),  width=8/1.57, height=6/1.57)
  ggplot(data=cidata_age_obs) + geom_line(aes(x=time, y=ci_ac, colour="Observed")) + 
    geom_line(aes(x=time, y=ci_ac, colour="Natural course"), data=cidata_age_nc) + 
#    geom_line(aes(x=time, y=ci_ac, colour="High exposure"), data=cidata_age_hi)  + 
#    geom_line(aes(x=time, y=ci_ac, colour="No exposure"), data=cidata_age_ne)  +
	  scale_colour_discrete("Intervention")
dev.off()

pdf(paste0(plotd, "gf_ints_rc_age",suff,".pdf"),  width=8/1.57, height=6/1.57)
	ggplot(data=cidata_age_obs) + geom_line(aes(x=time, y=ci_rc, colour="Observed")) + 
	  geom_line(aes(x=time, y=ci_rc, colour="Natural course"), data=cidata_age_nc) + 
#	  geom_line(aes(x=time, y=ci_rc, colour="High exposure"), data=cidata_age_hi)  + 
#	  geom_line(aes(x=time, y=ci_rc, colour="No exposure"), data=cidata_age_ne)  +
	  scale_colour_discrete("Intervention")
dev.off()

pdf(paste0(plotd, "gf_ints_Heart dis._age",suff,".pdf"),  width=8/1.57, height=6/1.57)
	ggplot(data=cidata_age_obs) + geom_line(aes(x=time, y=ci_cv, colour="Observed")) + 
	  geom_line(aes(x=time, y=ci_cv, colour="Natural course"), data=cidata_age_nc) + 
#	  geom_line(aes(x=time, y=ci_cv, colour="High exposure"), data=cidata_age_hi)  + 
#	  geom_line(aes(x=time, y=ci_cv, colour="No exposure"), data=cidata_age_ne)  +
	  scale_colour_discrete("Intervention")
dev.off()

pdf(paste0(plotd, "gf_ints_oc_age",suff,".pdf"),  width=8/1.57, height=6/1.57)
	ggplot(data=cidata_age_obs) + geom_line(aes(x=time, y=ci_oc, colour="Observed")) + 
	  geom_line(aes(x=time, y=ci_oc, colour="Natural course"), data=cidata_age_nc) +
#	  geom_line(aes(x=time, y=ci_oc, colour="High exposure" ), data=cidata_age_hi)  + 
#	  geom_line(aes(x=time, y=ci_oc, colour="No exposure"  ), data=cidata_age_ne)  + 
	  scale_colour_discrete("Intervention") 
dev.off()



pdf(paste0(plotd, "gf_ints_lw_age",suff,".pdf"),  width=8/1.57, height=6/1.57)
  ggplot(data=lw_age_obs) + geom_line(aes(x=time, y=cumhaz_lw, colour="Observed")) + 
	  geom_line(aes(x=time, y=cumhaz_lw, colour="Natural course"), data=lw_age_nc) + 
#	  geom_line(aes(x=time, y=cumhaz_lw, colour="High exposure" ), data=lw_age_hi)  + 
#	  geom_line(aes(x=time, y=cumhaz_lw, colour="No exposure"  ), data=lw_age_ne)  + 
	  scale_colour_discrete("Intervention")
dev.off()

pdf(paste0(plotd, "gf_ints_rw_age",suff,".pdf"),  width=8/1.57, height=6/1.57)
  ggplot(data=rw_age_obs) + geom_line(aes(x=time, y=cumhaz_rw, colour="Observed")) + 
    geom_line(aes(x=time, y=cumhaz_rw,  colour="Natural course"), data=rw_age_nc) + 
#	  geom_line(aes(x=time, y=cumhaz_rw,colour="High exposure" ), data=rw_age_hi)  + 
#	  geom_line(aes(x=time, y=cumhaz_rw,colour="No exposure"  ), data=rw_age_ne)  + 
	  scale_colour_discrete("Intervention")
dev.off()

#date as the time scale

pdf(paste0(plotd, "gf_ints_obs_date",suff,".pdf"),  width=8/1.57, height=6/1.57)
ggplot(data=cidata_date_obs) + geom_line(aes(x=time, y=ci_ac, colour="All causes", linetype="Observed")) + 
    geom_line(aes(x=time, y=ci_rc, colour="Respiratory cancer", linetype="Observed"), data=cidata_date_obs) + 
    geom_line(aes(x=time, y=ci_cv, colour="Cardiovascular disease", linetype="Observed"), data=cidata_date_obs) + 
    geom_line(aes(x=time, y=ci_oc, colour="Other causes", linetype="Observed"), data=cidata_date_obs) +
    geom_line(aes(x=time, y=ci_ac, colour="All causes", linetype="Natural course"), data=cidata_date_nc) + 
    geom_line(aes(x=time, y=ci_rc, colour="Respiratory cancer", linetype="Natural course"), data=cidata_date_nc) + 
    geom_line(aes(x=time, y=ci_cv, colour="Cardiovascular disease", linetype="Natural course"), data=cidata_date_nc) + 
    geom_line(aes(x=time, y=ci_oc, colour="Other causes", linetype="Natural course"), data=cidata_date_nc)
dev.off()

pdf(paste0(plotd, "gf_ints_nc_date",suff,".pdf"),  width=8/1.57, height=6/1.57)
  ggplot(data=cidata_date_nc) + geom_line(aes(x=time, y=ci_ac, colour="All causes")) + 
    geom_line(aes(x=time, y=ci_rc, colour="Respiratory cancer"), data=cidata_date_nc) + 
    geom_line(aes(x=time, y=ci_cv, colour="Cardiovascular disease"), data=cidata_date_nc) + 
    geom_line(aes(x=time, y=ci_oc, colour="Other causes"), data=cidata_date_nc)
dev.off()

pdf(paste0(plotd, "gf_ints_allcause_date",suff,".pdf"),  width=8/1.57, height=6/1.57)
  ggplot(data=cidata_date_obs) + geom_line(aes(x=time, y=ci_ac, colour="Observed")) + 
    geom_line(aes(x=time, y=ci_ac, colour="Natural course"), data=cidata_date_nc) + 
#    geom_line(aes(x=time, y=ci_ac, colour="High exposure" ), data=cidata_date_hi)  + 
#    geom_line(aes(x=time, y=ci_ac, colour="No exposure"  ), data=cidata_date_ne)   + 
	  scale_colour_discrete("Intervention")
dev.off()

pdf(paste0(plotd, "gf_ints_rc_date",suff,".pdf"),  width=8/1.57, height=6/1.57)
	ggplot(data=cidata_date_obs) + geom_line(aes(x=time, y=ci_rc, colour="Observed")) + 
	  geom_line(aes(x=time, y=ci_rc, colour="Natural course"), data=cidata_date_nc) + 
#	  geom_line(aes(x=time, y=ci_rc, colour="High exposure" ), data=cidata_date_hi)  + 
#	  geom_line(aes(x=time, y=ci_rc, colour="No exposure"  ), data=cidata_date_ne)  + 
	  scale_colour_discrete("Intervention")
dev.off()
pdf(paste0(plotd, "gf_ints_Heart dis._date",suff,".pdf"),  width=8/1.57, height=6/1.57)
	ggplot(data=cidata_date_obs) + geom_line(aes(x=time, y=ci_cv, colour="Observed")) + 
	  geom_line(aes(x=time, y=ci_cv, colour="Natural course"), data=cidata_date_nc) + 
#	  geom_line(aes(x=time, y=ci_cv, colour="High exposure" ), data=cidata_date_hi)  + 
#	  geom_line(aes(x=time, y=ci_cv, colour="No exposure"  ), data=cidata_date_ne)  + 
	  scale_colour_discrete("Intervention")
dev.off()

pdf(paste0(plotd, "gf_ints_oc_date",suff,".pdf"),  width=8/1.57, height=6/1.57)
	ggplot(data=cidata_date_obs) + geom_line(aes(x=time, y=ci_oc, colour="Observed")) + 
	  geom_line(aes(x=time, y=ci_oc,colour="Natural course"), data=cidata_date_nc) + 
#	  geom_line(aes(x=time, y=ci_oc,colour="High exposure" ), data=cidata_date_hi)  + 
#	  geom_line(aes(x=time, y=ci_oc,colour="No exposure"  ), data=cidata_date_ne)  + 
	  scale_colour_discrete("Intervention")
dev.off()



pdf(paste0(plotd, "gf_ints_lw_date",suff,".pdf"),  width=8/1.57, height=6/1.57)
  ggplot(data=lw_date_obs) + geom_line(aes(x=time, y=cumhaz_lw, colour="Observed")) + 
	  geom_line(aes(x=time, y=cumhaz_lw, colour="Natural course"), data=lw_date_nc) + 
#	  geom_line(aes(x=time, y=cumhaz_lw, colour="High exposure" ), data=lw_date_hi)  + 
#	  geom_line(aes(x=time, y=cumhaz_lw, colour="No exposure"  ), data=lw_date_ne)  + 
	  scale_colour_discrete("Intervention")
dev.off()

pdf(paste0(plotd, "gf_ints_rw_date",suff,".pdf"),  width=8/1.57, height=6/1.57)
  ggplot(data=rw_date_obs) + geom_line(aes(x=time, y=cumhaz_rw, colour="Observed")) + 
    geom_line(aes(x=time, y=cumhaz_rw,   colour="Natural course"), data=rw_date_nc) + 
#	  geom_line(aes(x=time, y=cumhaz_rw, colour="High exposure" ), data=rw_date_hi)  + 
#	  geom_line(aes(x=time, y=cumhaz_rw, colour="No exposure"  ), data=rw_date_ne)  + 
	  scale_colour_discrete("Intervention")
dev.off()




	ggplot(data=cidata_age_obs) + #geom_line(aes(x=time, y=ci_cv, colour="Observed")) + 
	  geom_line(aes(x=time, y=ci_cv, colour="Natural course"), data=cidata_age_nc, size=1.2) + 
	  geom_line(aes(x=time, y=ci_cv, colour="High exposure"), data=cidata_age_hi, size=1.2)  + 
    geom_line(aes(x=time, y=ci_cv, colour="No exposure"), data=cidata_age_ne, size=1.2)  +
	  geom_line(aes(x=time, y=ci_cv, colour="Natural course20"), data=cidata_age_nc_20, size=1.2) + 
	  geom_line(aes(x=time, y=ci_cv, colour="High exposure20"), data=cidata_age_hi_20, size=1.2)  + 
   geom_line(aes(x=time, y=ci_cv, colour="No exposure20"), data=cidata_age_ne_20, size=1.2)  +
     scale_x_continuous("Age") + scale_y_continuous("Cumulative incidence") +
   scale_colour_grey("Intervention", breaks=c("High exposure", "Natural course", "No exposure"), labels=c("High exposure", "Natural course", "No exposure")) + 
  theme_alex + theme(line=element_line(size=1.2), legend.position=c(0,1), 
  legend.justification=c(0,1))

	
		ggplot(data=cidata_age_obs) + #geom_line(aes(x=time, y=ci_rc, colour="Observed")) + 
	  geom_line(aes(x=time, y=ci_rc, colour="Natural course"), data=cidata_age_nc, size=1.2) + 
	  geom_line(aes(x=time, y=ci_rc, colour="High exposure"), data=cidata_age_hi, size=1.2)  + 
    geom_line(aes(x=time, y=ci_rc, colour="No exposure"), data=cidata_age_ne, size=1.2)  +
	  geom_line(aes(x=time, y=ci_rc, colour="Natural course20"), data=cidata_age_nc_20, size=1.2) + 
	  geom_line(aes(x=time, y=ci_rc, colour="High exposure20"), data=cidata_age_hi_20, size=1.2)  + 
    geom_line(aes(x=time, y=ci_rc, colour="No exposure20"), data=cidata_age_ne_20, size=1.2)  +
     scale_x_continuous("Age") + scale_y_continuous("Cumulative incidence") +
   scale_colour_grey("Intervention", breaks=c("High exposure", "Natural course", "No exposure"), labels=c("High exposure", "Natural course", "No exposure")) + 
  theme_alex + theme(line=element_line(size=1.2), legend.position=c(0,1), 
  legend.justification=c(0,1))

		
	ggplot(data=cidata_age_obs) + #geom_line(aes(x=time, y=ci_cv, colour="Observed")) + 
	  geom_line(aes(x=time, y=ci_oc, colour="Natural course"), data=cidata_age_nc, size=1.2) + 
	  geom_line(aes(x=time, y=ci_oc, colour="High exposure"), data=cidata_age_hi, size=1.2)  + 
    geom_line(aes(x=time, y=ci_oc, colour="No exposure"), data=cidata_age_ne, size=1.2)  +
	  geom_line(aes(x=time, y=ci_oc, colour="Natural course20"), data=cidata_age_nc_20, size=1.2) + 
	  geom_line(aes(x=time, y=ci_oc, colour="High exposure20"), data=cidata_age_hi_20, size=1.2)  + 
   geom_line(aes(x=time, y=ci_oc, colour="No exposure20"), data=cidata_age_ne_20, size=1.2)  +
     scale_x_continuous("Age") + scale_y_continuous("Cumulative incidence") +
   scale_colour_grey("Intervention", breaks=c("High exposure", "Natural course", "No exposure"), labels=c("High exposure", "Natural course", "No exposure")) + 
  theme_alex + theme(line=element_line(size=1.2), legend.position=c(0,1), 
  legend.justification=c(0,1))		
	
	ggplot(data=cidata_age_obs) + #geom_line(aes(x=time, y=ci_ac, colour="Observed")) + 
	  geom_line(aes(x=time, y=ci_ac, colour="Natural course"), data=cidata_age_nc, size=1.2) + 
	  geom_line(aes(x=time, y=ci_ac, colour="High exposure"), data=cidata_age_hi, size=1.2)  + 
    geom_line(aes(x=time, y=ci_ac, colour="No exposure"), data=cidata_age_ne, size=1.2)  +
	  geom_line(aes(x=time, y=ci_ac, colour="Natural course20"), data=cidata_age_nc_20, size=1.2) + 
	  geom_line(aes(x=time, y=ci_ac, colour="High exposure20"), data=cidata_age_hi_20, size=1.2)  + 
   geom_line(aes(x=time, y=ci_ac, colour="No exposure20"), data=cidata_age_ne_20, size=1.2)  +
     scale_x_continuous("Age") + scale_y_continuous("Cumulative incidence") +
   scale_colour_grey("Intervention", breaks=c("High exposure", "Natural course", "No exposure"), labels=c("High exposure", "Natural course", "No exposure")) + 
  theme_alex + theme(line=element_line(size=1.2), legend.position=c(0,1), 
  legend.justification=c(0,1))		