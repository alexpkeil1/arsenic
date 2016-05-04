######################################################################################################################
# Author: Alex Keil
# Program: mtcs_miscplots_20141017.R
# Language: R
# Date: Friday, October 17, 2014 at 4:36:07 PM
# Project: 
# Tasks:
# Data in: 
# Data out: 
# Description:
# Keywords:
# Released under the GNU General Public License: http://www.gnu.org/copyleft/gpl.html
######################################################################################################################


library(ggplot2)
library(foreign)
library(lubridate)
#library(sas7bdat)
library(haven)
library(grid)
library(gridExtra)
library(survival)
setwd("/Users/akeil/EpiProjects/MT_copper_smelters/data")
plotd = "/Users/akeil/EpiProjects/MT_copper_smelters/output/images/"




yrcen <- read_sas("mtcs_expcentiles_yr.sas7bdat")[-1,]
ggd <- as.data.frame(rbind(
cbind(50, yrcen$date_years, yrcen$cum_as_score_P50,yrcen$as_score_P50, yrcen$`_FREQ_`),
cbind(75, yrcen$date_years, yrcen$cum_as_score_P75,yrcen$as_score_P75,  yrcen$`_FREQ_`),
cbind(90, yrcen$date_years, yrcen$cum_as_score_P90,yrcen$as_score_P90, yrcen$`_FREQ_`),
cbind(95, yrcen$date_years, yrcen$cum_as_score_P95,yrcen$as_score_P95, yrcen$`_FREQ_`),
cbind(99, yrcen$date_years, yrcen$cum_as_score_P99,yrcen$as_score_P99, yrcen$`_FREQ_`),
cbind(0, yrcen$date_years, yrcen$cum_as_score_Sum, yrcen$as_score_Sum, yrcen$`_FREQ_`),
cbind(1, yrcen$date_years, yrcen$cum_as_score_Mean, yrcen$as_score_Mean, yrcen$`_FREQ_`)
))
names(ggd) <- c("Percentile", "Year", "CumExposure", "AnnExposure", "Nworkers")

str(yrcen)

agecen <- read_sas("mtcs_expcentiles_age.sas7bdat")[-1,]
gga <- as.data.frame(rbind(
cbind(50, agecen$age_years, agecen$cum_as_score_P50,agecen$as_score_P50, agecen$`_FREQ_`),
cbind(75, agecen$age_years, agecen$cum_as_score_P75,agecen$as_score_P75, agecen$`_FREQ_`),
cbind(90, agecen$age_years, agecen$cum_as_score_P90,agecen$as_score_P90, agecen$`_FREQ_`),
cbind(95, agecen$age_years, agecen$cum_as_score_P95,agecen$as_score_P95, agecen$`_FREQ_`),
cbind(99, agecen$age_years, agecen$cum_as_score_P99,agecen$as_score_P99, agecen$`_FREQ_`),
cbind(0, agecen$age_years, agecen$cum_as_score_Sum, agecen$as_score_Sum, agecen$`_FREQ_`),
cbind(1, agecen$age_years, agecen$cum_as_score_Mean, agecen$as_score_Mean, agecen$`_FREQ_`)
))
names(gga) <- c("Percentile", "Age", "CumExposure", "AnnExposure", "Nworkers")


theme_alex <- list(theme(
legend.position="none", 
panel.grid=element_blank(), 
panel.background=element_rect(fill="white", colour=NA), 
axis.text=element_text(face="bold", colour="black", size=18), 
axis.title=element_text(face="bold", size=18),
panel.border=element_blank(), 
axis.line = element_line(colour = "black", size=1),
strip.text.y = element_blank(),
strip.background=element_blank()
))

# plots
len = dim(ggd[ggd$Percentile %in% c(1),])[1]
pdata <- data.frame(fact=factor(c(rep(1, len), rep(2, len)), labels=c("Annual Exposure, mg/m^3", "Number of workers")), val = c(ggd[ggd$Percentile %in% c(1),"AnnExposure"], ggd[ggd$Percentile %in% c(1),"Nworkers"]), 
Year = c(ggd[ggd$Percentile %in% c(1),"Year"], ggd[ggd$Percentile %in% c(1),"Year"]))

#employment, exposure over time
gp <- ggplot(data=pdata, aes(x=Year, y=val)) + 
 geom_bar(data=pdata[pdata$fact=="Number of workers",], stat="identity") + 
 geom_line(data=pdata[pdata$fact=="Annual Exposure, mg/m^3",]) +
 geom_text(data=data.frame(fact=factor(c(1,2), labels=c("Annual Exposure, mg/m^3", "Number of workers")), x=c(1950, 1970), y=c(.395, 2300), label=c("atop(Annual~Exposure,~(mg/m^3))", "atop(Active,workers)")), aes(x,y,label=label), parse=TRUE) + 
 facet_grid(fact~., scales="free_y") + theme_alex + theme(axis.title.y=element_blank())
print(gp)
pdf(paste0(plotd, "ann_meanexposures.pdf"), width=10/1.57, height=6/1.57)
  gp   
dev.off()


#risk over time
obs <- read.csv("~/EpiProjects/MT_copper_smelters/output/GFORMULA_kmpics/gformula_observed.csv", header=TRUE)
s.obs.cvd <- survfit(Surv(agein_alt, ageout, d_cvd)~1, data=obs)
s.obs.rc <- survfit(Surv(agein_alt, ageout, d_respcancer)~1, data=obs)
s.obs.all <- survfit(Surv(agein_alt, ageout, d_allothercauses)~1, data=obs)
processSurv <- function(indata, addtime=TRUE){
	tdat <- with(indata, as.data.frame(cbind(time,n.risk, n.event, n.censor, n.enter, surv, std.err, upper, lower)))
	if(addtime) { 
		 tdat2 <- merge(tdat, data.frame(time=14:90), by="time", all=TRUE)
	     tdat2[order(tdat2$time),]
	     #sort of works, but not if too many times are missing
	     lagsurv = tdat2$surv
	     lagrisk = tdat2$n.risk
	     tdat2$n.event = ifelse(is.na(tdat2$n.event), 0, tdat2$n.event)
	     tdat2$n.censor = ifelse(is.na(tdat2$n.censor), 0, tdat2$n.censor)
	     tdat2$n.enter = ifelse(is.na(tdat2$n.enter), 0, tdat2$n.enter)
	     while(any(is.na(tdat2$surv))){
	     	lagsurv = c(1, lagsurv[-length(lagsurv)])
	     	lagrisk = c(1, lagrisk[-length(lagrisk)])
	     	tdat2$surv <- ifelse(is.na(tdat2$surv), lagsurv, tdat2$surv)
	     	tdat2$n.risk <- ifelse(is.na(tdat2$n.risk), lagrisk, tdat2$n.risk)
	     }
	return(tdat2)
	}	else return(tdat)
}
s.obs.cvd <-processSurv(s.obs.cvd, FALSE)
s.obs.rc <-processSurv(s.obs.rc, FALSE)
s.obs.all <-processSurv(s.obs.all, FALSE)

cvdtimes <- rep(s.obs.cvd$time, s.obs.cvd$n.event)
rctimes <- rep(s.obs.rc$time, s.obs.rc$n.event)
alltimes <- rep(s.obs.all$time, s.obs.all$n.event)

quantile(cvdtimes, p=c(0.5, 0.25, 0.75))
quantile(rctimes, p=c(0.5, 0.25, 0.75))
quantile(alltimes, p=c(0.5, 0.25, 0.75))

gpsim <- ggplot() + geom_bar(aes(x=alltimes), stat="bin", binwidth=2.5, fill="gray50", colour="gray60") + 
                  geom_bar(aes(x=cvdtimes), stat="bin", binwidth=2.5, fill="gray20", colour="black") + 
                  geom_bar(aes(x=rctimes), stat="bin", binwidth=2.5, fill="white", colour="gray60") + 
                  theme_alex 
gp2 = gpsim + scale_x_continuous(limits=c(min(alltimes), 90), name="Age") + geom_text(data=data.frame(x=c(70, 70, 65), y=c(165, 100, 15), label=c("Other","Heart dis.", "Resp. cancer")), aes(x=x,y=y,label=label), colour=c("black", "white", "black"), fontface=2, size=10) + scale_y_continuous(name="Number of deaths")
print(gp2)
pdf(paste0(plotd, "fig1.pdf"), width=12/1.57, height=8/1.57)
  gp2   
dev.off()


gp3 <- ggplot() + geom_line(data=s.obs.cvd, aes(x=time, y=n.risk), size=2) + theme_alex + 
 scale_x_continuous(limits=c(min(cvdtimes), 90), name="Age") +  scale_y_continuous(name="Number \nat risk")
print(gp3)
pdf(paste0(plotd, "atrisk_distn.pdf"), width=12/1.57, height=4/1.57)
  gp3   
dev.off()

br = c(30,60,90)
gpa = gp2 + scale_y_continuous(name="", breaks=c(0, 100,200), labels=c("0", " 100", "  200"))  + scale_x_continuous(name="Age", breaks=br)
gpb = gp3 + scale_y_continuous(name="", breaks=c(0,2000, 4000, 6000))  + scale_x_continuous(name="", breaks=br)

grid.newpage()
gl = grid.layout(nrow=2, ncol=1, heights=unit(c(.6,.4), "npc"))
pushViewport(viewport(layout=gl, x=0, y=0))
print(gpa, vp=viewport(x = unit(1, "npc"), y = unit(0.5, "npc"), just="bottom", height=unit(.6, "npc")))
print(gpb, vp=viewport(x = unit(1, "npc"), y = unit(1.05, "npc"), just="bottom", height=unit(0.4, "npc")))


#workforce over time (looking for evidence of labor disputes)
dtin <- as.Date(obs$datein_alt, format="%m/%d/%Y")
dtout <- as.Date(obs$dateout, format="%m/%d/%Y")
limx <- c(min(dtin), max(dtout))
limy <- c(min(obs$smid), max(obs$smid))

newpdat <- data.frame(smid = obs$smid, dtin=dtin, dtout=dtout, rw = obs$returnwork, lw = obs$leavework, ds=obs$start_fu)

newpdat <- newpdat[order(newpdat$ds, newpdat$smid, newpdat$dtin),]

plot.new()
plot.window(xlim=limx, ylim=limy)
with(newpdat, segments(x0=dtin, x1=dtout, y0=smid, y1=smid))
with(newpdat, points(dtout, smid, col="white", pch=19, cex=0.1*lw))
with(newpdat, points(dtout, smid, col="skyblue", pch=19, cex=0.1*rw))
abline(v=as.Date("1968-01-01"), col='red', lwd=2)
abline(v=as.Date("1966-01-01"), col='red', lwd=2)
axis.Date(1, newpdat$dtin)
axis(2, at=NULL, labels=NULL)


####### causes of death (ICD code)
icd <- read.csv("/Users/akeil/EpiProjects/MT_copper_smelters/data/icd-8-codes-clean.csv", stringsAsFactors = FALSE)
dat <- read_sas("/Users/akeil/EpiProjects/MT_copper_smelters/data/mtcs_dg02.sas7bdat")
coi <- dat[dat$icd>=160 & dat$icd<=163.9 | dat$icd>=410 & dat$icd<=414.9 | dat$icd>=420 & dat$icd<=429.9, ]
ocoi <- dat[dat$icd>=430 & dat$icd<=438.9 | dat$icd>=440 & dat$icd<=448.9 | dat$icd==402 | dat$icd==403| dat$icd==404, ]

oi <- as.data.frame(t(t(table(coi$icd))))[,c(1,3)]
names(oi) <- c("icdnum", "numdeaths")
oitab <- merge(oi, icd, all.x = TRUE, all.y=FALSE)

icd$ord <- 1:length(icd$icdnum)
all <- as.data.frame(t(t(table(dat$icd))))[,c(1,3)]
names(all) <- c("icdnum", "numdeaths")
alltab <- merge(icd, all, all.x = TRUE, all.y=TRUE)
alltab <- alltab[order(alltab$ord),]
alltab <- alltab[, -which(names(alltab)=="ord")]
alltab$ofinterest <- 1*(alltab$icdnum>=160 & alltab$icdnum<=163.9 | alltab$icdnum>=410 & alltab$icdnum<=414.9 | alltab$icdnum>=420 & alltab$icdnum<=429.9) +
                      2*(alltab$icdnum>=430 & alltab$icdnum<=438.9 | alltab$icdnum>=440 & alltab$icdnum<=448.9 | alltab$icdnum==402 | alltab$icdnum==403 | alltab$icdnum==404)

write.csv(alltab, "/Users/akeil/EpiProjects/MT_copper_smelters/data/deaths_by_icd.csv", row.names = FALSE, na="")


#ICD codes: to follow up 520 (anodontia), 795.0 (SIDS), 845 (occupant of spacecraft)

#looking at icd 163 by date
demo <- read_sas("mtcs_dg02.sas7bdat")
str(demo)
demo$yod <- year(as.Date(demo$dlo, origin="1960-01-01"))
demo$icd6 <- (demo$yod<=1964)
with(demo[demo$ICD3==163,], table(ICD3, icd6))

with(demo[demo$ICD3>=410 & demo$ICD3<=450,], table(ICD3, icd6))



# year of life lost
dt <- read.csv("~/EpiProjects/MT_copper_smelters/output/GFORMULA_kmpics/gformula_natcourse.csv", header=TRUE)
dt2 <- read.csv("~/EpiProjects/MT_copper_smelters/output/GFORMULA_kmpics/gformula_no_exposure_at_work.csv", header=TRUE)
dt3 <- read.csv("~/EpiProjects/MT_copper_smelters/output/GFORMULA_kmpics/gformula_hi_exposure_at_work.csv", header=TRUE)
obs <- read.csv("~/EpiProjects/MT_copper_smelters/output/GFORMULA_kmpics/gformula_observed.csv", header=TRUE)

yln <- sum(dt[dt$done==1 & dt$ageout<=90,]$cumpy)
yl0 <- sum(dt2[dt2$done==1 & dt2$ageout<=90,]$cumpy)
yl1 <- sum(dt3[dt3$done==1 & dt3$ageout<=90,]$cumpy)

ylnb <- sum(dt[dt$done==1 & dt$ageout<=70,]$cumpy)
yl0b <- sum(dt2[dt2$done==1 & dt2$ageout<=70,]$cumpy)
yl1b <- sum(dt3[dt3$done==1 & dt3$ageout<=70,]$cumpy)

sum(dt$done) #mcsamples
#number of deaths in cohort:
ndeaths = sum(demo$y_allcause)
n = dim(demo)[1]


#expected years of life lost among all subjects (up to age 90)
(yln-yl0)/sum(dt$done) # nat course minus unexposed: if exposure improves life span, this should be negative
(yl1-yl0)/sum(dt$done) # always hi minus unexposed: if exposure improves life span, this should be negative
(yl1-yln)/sum(dt$done) # always hi minus natural course: if exposure improves life span, this should be negative
#up to age 70 (somehow greater)
(ylnb-yl0b)/sum(dt$done)
(yl1b-yl0b)/sum(dt$done)
(yl1b-ylnb)/sum(dt$done)


#number hired pre 1938
sum(as.Date(demo$hiredate, origin="1960-01-01") < as.Date("1938-01-01"))/dim(demo)[1]




