# bootstrap estimates of differences in the exposure related excess mortality at 
#  different ages (additive risk difference modification)
#also included is a function to plot a bootstrap p-value function

library(ggplot2)
rdfun = function(dir = "/Users/akeil/EpiProjects/MT_copper_smelters/data/out/all_withmid/"){
   ls <- system(paste0("ls ", dir, " | grep cidat_all_"), intern=TRUE)
   for(i in 1:length(ls)){
    nm = gsub('.csv', '', gsub('_', 'dat', gsub("cidat_all__", "", ls[i])))
    cat(nm, ' ')
    dat = read.csv(paste0(dir, ls[i]), stringsAsFactors=FALSE)
    dat = dat[order(dat$file),]
    dat = dat[dat$file != "7_49",] #7_49 didn't make it into the low group
    assign(nm, dat, envir = parent.env(environment()))
   }
}
#read all ci summary files (including excess)
rdfun()

head(hidat70)
#which(!(hidat70$file %in% lodat70$file)) #7_49 didn't make it into the low group

all(hidat70$file == hidat60$file)
all(hidat70$file == lodat70$file)

#risk difference modification
int_test = function(dat70, dat60, out='ac'){
  (dat70[,paste0("excess_ci_", out)] - dat60[,paste0("excess_ci_", out)])
}

#risk ratio modification
intrat_test = function(dat70, dat60, out='ac'){
  (dat70[,paste0("ratio_ci_", out)] / dat60[,paste0("ratio_ci_", out)])
}

my_summary = function(x, alpha=0.05, mult=1000){
  res = round(mult*c(mean(x), quantile(x, alpha/2), quantile(x, 1-alpha/2), mean(x)+sd(x)*c(qnorm(alpha/2), qnorm(1-alpha/2))), min(3, 1000/mult))
  paste0(res[1], ' (', res[2], ', ', res[3],')    Wald:', ' (', res[4], ', ', res[5],')')
}
pl = function(msg='') {
  print(paste(c(rep('-', 20), msg, rep('-', 20)), collapse=''))
  }


pl("Table 2, checking results")
my_summary(obsdat70[,paste0("ci_ac")])
my_summary(obsdat70[,paste0("ci_rc")])
my_summary(obsdat70[,paste0("ci_cv")])
my_summary(obsdat70[,paste0("ci_oc")])

my_summary(hidat70[,paste0("excess_ci_ac")])
my_summary(hidat70[,paste0("excess_ci_rc")])
my_summary(hidat70[,paste0("excess_ci_cv")])
my_summary(hidat70[,paste0("excess_ci_oc")])

pl("Table 2 alternative, Risk ratios")
my_summary(ncdat70[,paste0("ratio_ci_ac")], mult=1)
my_summary(ncdat70[,paste0("ratio_ci_rc")], mult=1)
my_summary(ncdat70[,paste0("ratio_ci_cv")], mult=1)
my_summary(ncdat70[,paste0("ratio_ci_oc")], mult=1)

my_summary(lodat70[,paste0("ratio_ci_ac")], mult=1)
my_summary(lodat70[,paste0("ratio_ci_rc")], mult=1)
my_summary(lodat70[,paste0("ratio_ci_cv")], mult=1)
my_summary(lodat70[,paste0("ratio_ci_oc")], mult=1)

my_summary(meddat70[,paste0("ratio_ci_ac")], mult=1)
my_summary(meddat70[,paste0("ratio_ci_rc")], mult=1)
my_summary(meddat70[,paste0("ratio_ci_cv")], mult=1)
my_summary(meddat70[,paste0("ratio_ci_oc")], mult=1)

my_summary(hidat70[,paste0("ratio_ci_ac")], mult=1)
my_summary(hidat70[,paste0("ratio_ci_rc")], mult=1)
my_summary(hidat70[,paste0("ratio_ci_cv")], mult=1)
my_summary(hidat70[,paste0("ratio_ci_oc")], mult=1)


pl("Table 2, 90% confidence intervals")
my_summary(hidat70[,paste0("excess_ci_ac")], 0.1)
my_summary(hidat70[,paste0("excess_ci_rc")], 0.1)
my_summary(hidat70[,paste0("excess_ci_cv")], 0.1)
my_summary(hidat70[,paste0("excess_ci_oc")], 0.1)


pl("Table S4")
#Table S4
my_summary(nedat60[,("ci_ac")])
my_summary(nedat60[,("ci_rc")])
my_summary(nedat60[,("ci_cv")])
my_summary(nedat60[,("ci_oc")])
pl("Table S4 cont")
my_summary(ncdat60[,("excess_ci_ac")])
my_summary(ncdat60[,("excess_ci_rc")])
my_summary(ncdat60[,("excess_ci_cv")])
my_summary(ncdat60[,("excess_ci_oc")])
pl("Table S4 cont")
my_summary(lodat60[,("excess_ci_ac")])
my_summary(lodat60[,("excess_ci_rc")])
my_summary(lodat60[,("excess_ci_cv")])
my_summary(lodat60[,("excess_ci_oc")])
pl("Table S4 cont")
my_summary(meddat60[0("excess_ci_ac")])
my_summary(meddat60[0("excess_ci_rc")])
my_summary(meddat60[0("excess_ci_cv")])
my_summary(meddat60[0("excess_ci_oc")])
pl("Table S4 cont")
my_summary(hidat60[,("excess_ci_ac")])
my_summary(hidat60[,("excess_ci_rc")])
my_summary(hidat60[,("excess_ci_cv")])
my_summary(hidat60[,("excess_ci_oc")])
pl();pl()

pl("Table S4 alternative, Risk ratios")
my_summary(ncdat60[,paste0("ratio_ci_ac")], mult=1)
my_summary(ncdat60[,paste0("ratio_ci_rc")], mult=1)
my_summary(ncdat60[,paste0("ratio_ci_cv")], mult=1)
my_summary(ncdat60[,paste0("ratio_ci_oc")], mult=1)
pl("Table S4 alternative, cont")
my_summary(lodat60[,paste0("ratio_ci_ac")], mult=1)
my_summary(lodat60[,paste0("ratio_ci_rc")], mult=1)
my_summary(lodat60[,paste0("ratio_ci_cv")], mult=1)
my_summary(lodat60[,paste0("ratio_ci_oc")], mult=1)
pl("Table S4 alternative, cont")
my_summary(meddat60[,paste0("ratio_ci_ac")], mult=1)
my_summary(meddat60[,paste0("ratio_ci_rc")], mult=1)
my_summary(meddat60[,paste0("ratio_ci_cv")], mult=1)
my_summary(meddat60[,paste0("ratio_ci_oc")], mult=1)
pl("Table S4 alternative, cont")
my_summary(hidat60[,paste0("ratio_ci_ac")], mult=1)
my_summary(hidat60[,paste0("ratio_ci_rc")], mult=1)
my_summary(hidat60[,paste0("ratio_ci_cv")], mult=1)
my_summary(hidat60[,paste0("ratio_ci_oc")], mult=1)


pl("Table S5: additive modification of the risk difference")
#testing age modification of the risk difference
my_summary(int_test(ncdat70, ncdat60, 'ac'), .2)
my_summary(int_test(ncdat70, ncdat60, 'rc'), .2)
my_summary(int_test(ncdat70, ncdat60, 'cv'), .2)
my_summary(int_test(ncdat70, ncdat60, 'oc'), .2)
pl("Table S5, cont")
my_summary(int_test(lodat70, lodat60, 'ac'), .2)
my_summary(int_test(lodat70, lodat60, 'rc'), .2)
my_summary(int_test(lodat70, lodat60, 'cv'), .2)
my_summary(int_test(lodat70, lodat60, 'oc'), .2)
pl("Table S5, cont")
my_summary(int_test(meddat70, meddat60, 'ac'), .2)
my_summary(int_test(meddat70, meddat60, 'rc'), .2)
my_summary(int_test(meddat70, meddat60, 'cv'), .2)
my_summary(int_test(meddat70, meddat60, 'oc'), .2)
pl("Table S5, cont")
my_summary(int_test(hidat70, hidat60, 'ac'), .2)
my_summary(int_test(hidat70, hidat60, 'rc'), .2)
my_summary(int_test(hidat70, hidat60, 'cv'), .2)
my_summary(int_test(hidat70, hidat60, 'oc'), .2)

#testing age modification of the risk ratio
my_summary(intrat_test(ncdat70, ncdat60, 'ac'), .2, 1)
my_summary(intrat_test(ncdat70, ncdat60, 'rc'), .2, 1)
my_summary(intrat_test(ncdat70, ncdat60, 'cv'), .2, 1)
my_summary(intrat_test(ncdat70, ncdat60, 'oc'), .2, 1)
pl("Table S5, cont")
my_summary(intrat_test(lodat70, lodat60, 'ac'), .2, 1)
my_summary(intrat_test(lodat70, lodat60, 'rc'), .2, 1)
my_summary(intrat_test(lodat70, lodat60, 'cv'), .2, 1)
my_summary(intrat_test(lodat70, lodat60, 'oc'), .2, 1)
pl("Table S5, cont")
my_summary(intrat_test(meddat70, meddat60, 'ac'), .2, 1)
my_summary(intrat_test(meddat70, meddat60, 'rc'), .2, 1)
my_summary(intrat_test(meddat70, meddat60, 'cv'), .2, 1)
my_summary(intrat_test(meddat70, meddat60, 'oc'), .2, 1)
pl("Table S5, cont")
my_summary(intrat_test(hidat70, hidat60, 'ac'), .2, 1)
my_summary(intrat_test(hidat70, hidat60, 'rc'), .2, 1)
my_summary(intrat_test(hidat70, hidat60, 'cv'), .2, 1)
my_summary(intrat_test(hidat70, hidat60, 'oc'), .2, 1)

#testing age modification of the risk difference
# age 70;
pl("EMM continued, age 50")
my_summary(int_test(ncdat70, ncdat50, 'ac'), .2)
my_summary(int_test(ncdat70, ncdat50, 'rc'), .2)
my_summary(int_test(ncdat70, ncdat50, 'cv'), .2)
my_summary(int_test(ncdat70, ncdat50, 'oc'), .2)
pl("EMM, age 50")
my_summary(int_test(lodat70, lodat50, 'ac'), .2)
my_summary(int_test(lodat70, lodat50, 'rc'), .2)
my_summary(int_test(lodat70, lodat50, 'cv'), .2)
my_summary(int_test(lodat70, lodat50, 'oc'), .2)
pl("EMM, age 50")
my_summary(int_test(meddat70, meddat50, 'ac'), .2)
my_summary(int_test(meddat70, meddat50, 'rc'), .2)
my_summary(int_test(meddat70, meddat50, 'cv'), .2)
my_summary(int_test(meddat70, meddat50, 'oc'), .2)
pl("EMM, age 50")
my_summary(int_test(hidat70, hidat50, 'ac'), .2)
my_summary(int_test(hidat70, hidat50, 'rc'), .2)
my_summary(int_test(hidat70, hidat50, 'cv'), .2)
my_summary(int_test(hidat70, hidat50, 'oc'), .2)



#empirical p-value function
e_pvf <- function(x, tails=2){
 xseq = c(seq(0.0001, 0.001, 0.00001), seq(0.001, tails/2, 0.001))
 p = paste("<", 0.0001)
 cn = paste(">", quantile(x, 1-0.0001/tails)*1000)
 res = matrix(ncol = 3, nrow=length(xseq))
 res[,1] = xseq
 i=1
 for(alpha in xseq){
  res[i, 2:3] = c(quantile(x, alpha/tails), quantile(x, 1-alpha/tails))*1000
  if(i > 1 && res[i, 2]>0 && res[i-1,2] <= 0) {
    p = alpha
    cn = res[i, 3]
  }
  i = i+1
 }
 df = data.frame(res)
 names(df) = c('alpha', 'lower', 'upper')
 
 plt = ggplot(data=df) + geom_line(aes(lower, alpha)) + geom_line(aes(upper, alpha)) + 
  theme_bw() + scale_x_continuous(name="Excess deaths") + 
  scale_y_continuous(name="P-value") + geom_vline(aes(xintercept=0)) +
   geom_hline(aes(yintercept=0.05), linetype=3)
 cat(paste('P-value:', p))
 cat(paste('\nCounternull:', cn))
 print(plt)
 return(df)
}

epv = e_pvf(hidat70[,("excess_ci_ac")])
epv = e_pvf(hidat70[,("excess_ci_oc")])
#p-value representing a probability the result is >0? (one sided test?)
2*(sum(hidat70[,("excess_ci_oc")]<0)/length(hidat70[,("excess_ci_oc")]))
2*(1-pnorm(mean(hidat70[,("excess_ci_oc")])/sd(hidat70[,("excess_ci_oc")])))


pl()
#age 70
epv = e_pvf(hidat70[,("excess_ci_rc")])
epv = e_pvf(meddat70[,("excess_ci_rc")])
epv = e_pvf(lodat70[,("excess_ci_rc")])
epv = e_pvf(ncdat70[,("excess_ci_rc")])
pl()
#age 70
epv = e_pvf(hidat70[,("excess_ci_cv")])
epv = e_pvf(meddat70[,("excess_ci_cv")])
epv = e_pvf(lodat70[,("excess_ci_cv")])
epv = e_pvf(ncdat70[,("excess_ci_cv")])

pl()
#age 60
epv = e_pvf(hidat60[,("excess_ci_rc")])
epv = e_pvf(meddat60[,("excess_ci_rc")])
epv = e_pvf(lodat60[,("excess_ci_rc")])
epv = e_pvf(ncdat60[,("excess_ci_rc")])

pl()
#age 60
epv = e_pvf(hidat60[,("excess_ci_cv")])
epv = e_pvf(meddat60[,("excess_ci_cv")])
epv = e_pvf(lodat60[,("excess_ci_cv")])
epv = e_pvf(ncdat60[,("excess_ci_cv")])

pl()
#age 50
epv = e_pvf(hidat50[,("excess_ci_rc")])
epv = e_pvf(meddat50[,("excess_ci_rc")])
epv = e_pvf(lodat50[,("excess_ci_rc")])
epv = e_pvf(ncdat50[,("excess_ci_rc")])

pl()
#age 50
epv = e_pvf(hidat50[,("excess_ci_cv")])
epv = e_pvf(meddat50[,("excess_ci_cv")])
epv = e_pvf(lodat50[,("excess_ci_cv")])
epv = e_pvf(ncdat50[,("excess_ci_cv")])



#one tailed test
epv = e_pvf(hidat70[,("excess_ci_cv")], 1)

