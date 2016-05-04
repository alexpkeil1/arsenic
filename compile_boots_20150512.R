#edited on 2/25/16

#turn bootstrap estimates into risk differences, generate distributions for reporting in tables
library("haven")
setwd("/Users/akeil/EpiProjects/MT_copper_smelters/data/out/all")




booty <- function(age=70){
  obs <- read_sas(paste0("sbootage", age, "obs", ".sas7bdat"))
  nc <- read_sas(paste0("sbootage", age, "nc", ".sas7bdat"))
  ne <- read_sas(paste0("sbootage", age, "ne", ".sas7bdat"))
  hi <- read_sas(paste0("sbootage", age, "hi", ".sas7bdat"))
  obsdist <- t(apply(obs[,7:10], 2, function(x) cbind(mean=mean(x), sd=sd(x), q2_5=quantile(x, 0.025), q97_5=quantile(x, 0.975))))
  ncdist <- t(apply(nc[,7:10], 2, function(x) cbind(mean=mean(x), sd=sd(x), q2_5=quantile(x, 0.025), q97_5=quantile(x, 0.975))))
  nedist <- t(apply(ne[,7:10], 2, function(x) cbind(mean=mean(x), sd=sd(x), q2_5=quantile(x, 0.025), q97_5=quantile(x, 0.975))))
  hidist <- t(apply(hi[,7:10], 2, function(x) cbind(mean=mean(x), sd=sd(x), q2_5=quantile(x, 0.025), q97_5=quantile(x, 0.975))))
  rddist1 <- t(apply((hi[,7:10]-nc[,7:10]), 2, function(x) cbind(mean=mean(x), sd=sd(x), q2_5=quantile(x, 0.025), q97_5=quantile(x, 0.975))))
  
  rddist2 <- t(apply((ne[,7:10]-nc[,7:10]), 2, function(x) cbind(mean=mean(x), sd=sd(x), q2_5=quantile(x, 0.025), q97_5=quantile(x, 0.975))))
  out=rbind(obs=NA, obsdist, nc=NA, ncdist,ne=NA, nedist,hi=NA, hidist,rd_hi_nc=NA, rddist1,rd_ne_nc=NA, rddist2)
  out <- cbind(out, out[,1]-1.96*out[,2])
  out <- cbind(out, out[,1]+1.96*out[,2])
  colnames(out) <- c("mean", "sd", "q2_5", "q97_5", "waldlower", "waldupper")
  out
}


nice_booty <- function(age=80, ref="nc", mult=1, digits=NULL){
  if((ref != "nc") & (ref != "ne")) stop("ref should equal 'nc' or 'ne'")
  obs <- read_sas(paste0("sbootage", age, "obs", ".sas7bdat"))
  nc <- read_sas(paste0("sbootage", age, "nc", ".sas7bdat"))
  ne <- read_sas(paste0("sbootage", age, "ne", ".sas7bdat"))
  hi <- read_sas(paste0("sbootage", age, "hi", ".sas7bdat"))
  obsdist <- t(apply(obs[,7:10], 2, function(x) cbind(mean=mean(x), sd=sd(x), q2_5=quantile(x, 0.025), q97_5=quantile(x, 0.975))))
  ncdist <- t(apply(nc[,7:10], 2, function(x) cbind(mean=mean(x), sd=sd(x), q2_5=quantile(x, 0.025), q97_5=quantile(x, 0.975))))
  nedist <- t(apply(ne[,7:10], 2, function(x) cbind(mean=mean(x), sd=sd(x), q2_5=quantile(x, 0.025), q97_5=quantile(x, 0.975))))
  hidist <- t(apply(hi[,7:10], 2, function(x) cbind(mean=mean(x), sd=sd(x), q2_5=quantile(x, 0.025), q97_5=quantile(x, 0.975))))
#reference = natural course
  if(ref=="nc"){
    rddist0 <- t(apply((nc[,7:10]-nc[,7:10]), 2, function(x) cbind(mean=mean(x), sd=sd(x), q2_5=quantile(x, 0.025), q97_5=quantile(x, 0.975))))
    rddist1 <- t(apply((hi[,7:10]-nc[,7:10]), 2, function(x) cbind(mean=mean(x), sd=sd(x), q2_5=quantile(x, 0.025), q97_5=quantile(x, 0.975))))
    rddist2 <- t(apply((ne[,7:10]-nc[,7:10]), 2, function(x) cbind(mean=mean(x), sd=sd(x), q2_5=quantile(x, 0.025), q97_5=quantile(x, 0.975))))
  }
#reference = natural course
  if(ref=="ne"){
    rddist0 <- t(apply((nc[,7:10]-ne[,7:10]), 2, function(x) cbind(mean=mean(x), sd=sd(x), q2_5=quantile(x, 0.025), q97_5=quantile(x, 0.975))))
    rddist1 <- t(apply((hi[,7:10]-ne[,7:10]), 2, function(x) cbind(mean=mean(x), sd=sd(x), q2_5=quantile(x, 0.025), q97_5=quantile(x, 0.975))))
    rddist2 <- t(apply((ne[,7:10]-ne[,7:10]), 2, function(x) cbind(mean=mean(x), sd=sd(x), q2_5=quantile(x, 0.025), q97_5=quantile(x, 0.975))))
  }

  neworder <- c(1,2,3,4,1) #order in: all, rc, cvd, other
  if(ref=="ne") {
    causelist <- list(nedist[neworder,], ncdist[neworder,], hidist[neworder,])
    rdlist <- list(rddist2[neworder,], rddist0[neworder,], rddist1[neworder,])
  }
  if(ref=="nc") {
    causelist <- list(ncdist[neworder,], nedist[neworder,], hidist[neworder,])
    rdlist <- list(rddist0[neworder,], rddist2[neworder,], rddist1[neworder,])
  }
  
  #outtab <- matrix(ncol=7, nrow=4*4) #dropped NNT
  outtab <- matrix(ncol=6, nrow=4*4)
  row=0
  for(cause in 1:4){
    row=row+1
    for(int in 1:3){
      row=row+1
      #risk, ci
       outtab[row, 1] <- causelist[[int]][cause, 1]
       outtab[row, 2] <- causelist[[int]][cause, 1]-1.96*causelist[[int]][cause, 2]
       outtab[row, 3] <- causelist[[int]][cause, 1]+1.96*causelist[[int]][cause, 2]
      
      #risk difference, ci
       outtab[row, 4] <- rdlist[[int]][cause,1]
       outtab[row, 5] <- rdlist[[int]][cause,1]-1.96*rdlist[[int]][cause,2]
       outtab[row, 6] <- rdlist[[int]][cause,1]+1.96*rdlist[[int]][cause,2]
    }
  }
  outtab = outtab*mult #to give excess deaths per mult
  if(!is.null(digits)) outtab <- round(outtab, digits)
  #outtab[,7] <- 1/outtab[,4] ##nnt, dropped
  colnames(outtab) <- c("risk", "risk_low", "risk_upper", "rd", "rd_low", "rd_upper")
#  colnames(outtab) <- c("risk", "risk_low", "risk_upper", "rd", "rd_low", "rd_upper", "NNT")
  outtab[c(1,5,9,13),1] <- c("All causes", "RC","Heart disease", "Other")
  if(ref=="nc"){
    rownames(outtab) <- rep(c("Cause of death", "Natural course", "No exposure", "If at work heavy exposure"), 4)
    }
  if(ref=="ne"){
    rownames(outtab) <- rep(c("Cause of death","No exposure", "Natural course", "If at work heavy exposure"), 4)
    }
  outtab
}

paren.booty <- function(nice_booty_tab){
  nb2 <- nice_booty_tab
  restab <- 
    cbind(
    matrix(apply(nb2[,], 1, function(x) paste0(x[1], " (", x[2], ', ', x[3], ")")), ncol=4, nrow=4,byrow=TRUE),
    matrix(apply(nb2[,], 1, function(x) paste0(x[4], " (", x[5], ', ', x[6], ")")), ncol=4, nrow=4,byrow=TRUE)
    )
  tab <- as.data.frame(restab[,-c(5,6)])
  tab[,1] <- gsub("NA", "",gsub("[(),]", "",tab[,1]))
  colnames(tab) <- c("Disease", "None - CI", "Nat course - CI", "Heavy - CI", "Nat course - RD", "Heavy - RD")
  tab
}

(nb2 <- nice_booty(age=70, ref='ne', mult=1000, digits=1))
paren.booty(nb2)

write.csv(nice_booty(age=60), file="boot_age_60_noxref.csv")
write.csv(nice_booty(age=70), file="boot_age_70_noxref.csv")
write.csv(nice_booty(age=80), file="boot_age_80_noxref.csv")
write.csv(nice_booty(age=90), file="boot_age_90_noxref.csv")

#cleaner version
write.csv(paren.booty(nice_booty(age=60, ref='ne', mult=1000, digits=1)), file="boot_age_60_noxref.csv")
write.csv(paren.booty(nice_booty(age=70, ref='ne', mult=1000, digits=0)), file="boot_age_70_noxref.csv")
write.csv(paren.booty(nice_booty(age=80, ref='ne', mult=1000, digits=1)), file="boot_age_80_noxref.csv")
write.csv(paren.booty(nice_booty(age=90, ref='ne', mult=1000, digits=1)), file="boot_age_90_noxref.csv")




