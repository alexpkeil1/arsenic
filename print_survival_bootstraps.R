

plotd = "~/EpiProjects/MT_copper_smelters/output/images/"

library(survival)
library(sampling)
obs <- read.csv("~/EpiProjects/MT_copper_smelters/output/GFORMULA_kmpics/gformula_observed.csv", header=TRUE)
nc <- read.csv("~/EpiProjects/MT_copper_smelters/output/GFORMULA_kmpics/gformula_natcourse.csv", header=TRUE)

obs$d_allcause = obs$d_cvd + obs$d_respcancer + obs$d_allothercauses
nc$d_allcause = nc$d_cvd + nc$d_respcancer + nc$d_allothercauses

s.obs.lw <- survfit(Surv(agestart_alt, ageout, leavework)~1, data=obs)
s.obs.rw <- survfit(Surv(agestart_alt, ageout, returnwork)~1, data=obs)
s.obs.cvd <- survfit(Surv(agestart_alt, ageout, d_cvd)~1, data=obs)
s.obs.all <- survfit(Surv(agestart_alt, ageout, d_allothercauses)~1, data=obs)
s.obs.rc <- survfit(Surv(agestart_alt, ageout, d_respcancer)~1, data=obs)
s.obs.any <- survfit(Surv(agestart_alt, ageout, d_allcause)~1, data=obs)
s.obs.lw <- with(s.obs.lw, as.data.frame(cbind(time,n.risk, n.event, n.censor, n.enter, surv, std.err, upper, lower)))
s.obs.rw <- with(s.obs.rw, as.data.frame(cbind(time,n.risk, n.event, n.censor, n.enter, surv, std.err, upper, lower)))



plot.boot <- function(ds, outcome, iter, title=NULL){
par(mar=c(4,4,3,0.5), font.lab=2, font.axis=2)
ds <- with(ds, as.data.frame(cbind(time,n.risk, n.event, n.censor, n.enter, surv, std.err, upper, lower)))
plot( ds$time,1-ds$surv, lwd=2, type="l", xlab="Age", ylab="1-KM", main=title)
for(i in 1:iter){
 samp <- cluster(data=obs, clustername="smid", size=8014, method="srswr")
 newdat <- getdata(obs, samp)
 sfit <- survfit(Surv(agestart_alt, ageout, newdat[,outcome])~1, data=newdat, weight=Replicates,)
 sfit <- with(sfit, as.data.frame(cbind(time,n.risk, n.event, n.censor, n.enter, surv, std.err, upper, lower)))
 lines(sfit$time,1-sfit$surv,  col=rgb(0,0,0, alpha=0.05), lwd=3)
 cat(i, " ")
}
lines( ds$time,1-ds$surv, lwd=2)
}

#dev.new()

plot.boot(s.obs.cvd, outcome="d_cvd", 20)
 s.nc.cvd <- survfit(Surv(agestart_alt, ageout, d_cvd)~1, data=nc)
 s.nc.cvd <- with(s.nc.cvd, as.data.frame(cbind(time,n.risk, n.event, n.censor, n.enter, surv, std.err, upper, lower)))
 dev.copy(pdf, paste0(plotd, "km_cvd.pdf"),  width=8/1.57, height=6/1.57)
 dev.off()
 lines(s.nc.cvd$time, 1-s.nc.cvd$surv, type="l",lty=1, lwd=4, col=rgb(1,0,0, .65))
 dev.copy(pdf, paste0(plotd, "km_cvd2.pdf"),  width=8/1.57, height=6/1.57)
dev.off()

plot.boot(s.obs.rc, outcome="d_respcancer", 20)
 s.nc.rc <- survfit(Surv(agestart_alt, ageout, d_respcancer)~1, data=nc)
 s.nc.rc <- with(s.nc.rc, as.data.frame(cbind(time,n.risk, n.event, n.censor, n.enter, surv, std.err, upper, lower)))
 dev.copy(pdf, paste0(plotd, "km_rc.pdf"),  width=8/1.57, height=6/1.57)
 dev.off()
 lines(s.nc.rc$time, 1-s.nc.rc$surv, type="l",lty=1, lwd=4, col="red")
 dev.copy(pdf, paste0(plotd, "km_rc2.pdf"),  width=8/1.57, height=6/1.57)
dev.off()

plot.boot(s.obs.all, outcome="d_allothercauses", 20)
 s.nc.all <- survfit(Surv(agestart_alt, ageout, d_allothercauses)~1, data=nc)
 s.nc.all <- with(s.nc.all, as.data.frame(cbind(time,n.risk, n.event, n.censor, n.enter, surv, std.err, upper, lower)))
  dev.copy(pdf, paste0(plotd, "km_other.pdf"),  width=8/1.57, height=6/1.57)
 dev.off()
 lines(s.nc.all$time, 1-s.nc.all$surv, type="l",lty=1, lwd=4, col="red")
 dev.copy(pdf, paste0(plotd, "km_other2.pdf"),  width=8/1.57, height=6/1.57)
dev.off()

plot.boot(s.obs.any, outcome="d_allcause", 20)
 s.nc.any <- survfit(Surv(agestart_alt, ageout, d_allcause)~1, data=nc)
 s.nc.any <- with(s.nc.any, as.data.frame(cbind(time,n.risk, n.event, n.censor, n.enter, surv, std.err, upper, lower)))
  dev.copy(pdf, paste0(plotd, "km_all.pdf"),  width=8/1.57, height=6/1.57)
 dev.off()
 lines(s.nc.any$time, 1-s.nc.any$surv, type="l",lty=1, lwd=4, col="red")
 dev.copy(pdf, paste0(plotd, "km_all2.pdf"),  width=8/1.57, height=6/1.57)
dev.off()


