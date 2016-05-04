import sas7bdat as sas
#import pandas as pd
import matplotlib.pyplot as plt



obs = sas.SAS7BDAT('/Users/akeil/EpiProjects/MT_copper_smelters/data/mcdata/cidata_age_obs.sas7bdat').to_data_frame()
nc = sas.SAS7BDAT('/Users/akeil/EpiProjects/MT_copper_smelters/data/mcdata/cidata_age_nc.sas7bdat').to_data_frame()
ne = sas.SAS7BDAT('/Users/akeil/EpiProjects/MT_copper_smelters/data/mcdata/cidata_age_ne.sas7bdat').to_data_frame()
hi = sas.SAS7BDAT('/Users/akeil/EpiProjects/MT_copper_smelters/data/mcdata/cidata_age_hi.sas7bdat').to_data_frame()
lo = sas.SAS7BDAT('/Users/akeil/EpiProjects/MT_copper_smelters/data/mcdata/cidata_age_lo.sas7bdat').to_data_frame()
med = sas.SAS7BDAT('/Users/akeil/EpiProjects/MT_copper_smelters/data/mcdata/cidata_age_med.sas7bdat').to_data_frame()

def rgbit(tup):
    return (tup[0]/255, tup[1]/255, tup[2]/255)

colac = rgbit((104,194,194))
colrc = rgbit((252,120,85))
colcv = rgbit((169,152,199))
coloc = rgbit((111,174,148))

plt.figure(figsize=(10, 8), dpi=100)
plt.plot(obs.ageout, obs.ci_ac, label="Observed, All cause", color=colac)
plt.plot(obs.ageout, obs.ci_rc, label="Observed, Resp. Can.", color=colrc)
plt.plot(obs.ageout, obs.ci_cv, label="Observed, Heart Dis.", color=colcv)
plt.plot(obs.ageout, obs.ci_oc, label="Observed, Other", color=coloc)
plt.plot(nc.ageout, nc.ci_ac, label="Natural course, All cause", linestyle='dashed', color=colac)
plt.plot(nc.ageout, nc.ci_rc, label="Natural course, Resp. Can.", linestyle='dashed', color=colrc)
plt.plot(nc.ageout, nc.ci_cv, label="Natural course, Heart Dis.", linestyle='dashed', color=colcv)
plt.plot(nc.ageout, nc.ci_oc, label="Natural course, Other", linestyle='dashed', color=coloc)
plt.xlim(20,90)
plt.xlabel("Age", size=14)
plt.ylabel("Risk", size=14)
plt.legend(loc='best')


colnat = rgbit((104,194,194))
colno = rgbit((0,0,0))
collo = rgbit((169,152,199))
colmed = rgbit((111,174,148))
colhi = rgbit((252,120,85))

plt.figure(figsize=(10, 8), dpi=100)
plt.title("All cause")
plt.plot(hi.ageout, hi.ci_ac, label="Heavy", linestyle='-', color=colhi)
plt.plot(med.ageout, med.ci_ac, label="Medium", linestyle='-.', color=colmed)
plt.plot(nc.ageout, nc.ci_ac, label="Natural course", linestyle='-', color=colnat)
plt.plot(lo.ageout, lo.ci_ac, label="Low exposure", linestyle=':', color=collo)
plt.plot(ne.ageout, ne.ci_ac, label="No exposure", linestyle='--', color=colno)
plt.xlabel("Age")
plt.ylabel("Cumulative Incidence")
plt.legend(loc='best')

plt.figure(figsize=(6, 4), dpi=100)
#plt.title("Respiratory cancer", size=18)
plt.plot(hi.ageout, hi.ci_rc, label="Heavy exposure", linestyle='-', color=colhi, linewidth=3)
plt.plot(med.ageout, med.ci_rc, label="Medium exposure", linestyle='-', color=colmed, linewidth=3)
#plt.plot(nc.ageout, nc.ci_rc, label="Natural course", linestyle='-', color=colnat, linewidth=2)
plt.plot(lo.ageout, lo.ci_rc, label="Low exposure", linestyle='-', color=collo, linewidth=3)
plt.plot(ne.ageout, ne.ci_rc, label="No exposure", linestyle='-', color=colno, linewidth=3)
plt.xlim(20,90)
plt.xlabel("Age", size=14)
plt.ylabel("Risk", size=14)
plt.legend(loc='best')

plt.figure(figsize=(10, 8), dpi=100)
plt.title("Heart disease")
plt.plot(hi.ageout, hi.ci_cv, label="Heavy", linestyle='-', color=colhi, linewidth=2)
plt.plot(med.ageout, med.ci_cv, label="Medium", linestyle='-.', color=colmed, linewidth=2)
plt.plot(nc.ageout, nc.ci_cv, label="Natural course", linestyle='-', color=colnat, linewidth=2)
plt.plot(lo.ageout, lo.ci_cv, label="Low exposure", linestyle=':', color=collo, linewidth=2)
plt.plot(ne.ageout, ne.ci_cv, label="No exposure", linestyle='--', color=colno, linewidth=2)
plt.xlim(20,90)
plt.xlabel("Age", size=14)
plt.ylabel("Risk", size=14)
plt.legend(loc='best')


plt.figure(figsize=(10, 8), dpi=100)
plt.title("Other causes")
plt.plot(hi.ageout, hi.ci_oc, label="Heavy", linestyle='-', color=colhi, linewidth=2)
plt.plot(med.ageout, med.ci_oc, label="Medium", linestyle='-.', color=colmed, linewidth=2)
plt.plot(nc.ageout, nc.ci_oc, label="Natural course", linestyle='-', color=colnat, linewidth=2)
plt.plot(lo.ageout, lo.ci_oc, label="Low exposure", linestyle=':', color=collo, linewidth=2)
plt.plot(ne.ageout, ne.ci_oc, label="No exposure", linestyle='--', color=colno, linewidth=2)
plt.xlim(20,90)
plt.xlabel("Age", size=14)
plt.ylabel("Risk", size=14)
plt.legend(loc='best')



#risk
hiidx = ((hi.ageout>69.999) & (hi.ageout<70.001))
medidx = ((med.ageout>69.999) & (med.ageout<70.001))
loidx = ((lo.ageout>69.999) & (lo.ageout<70.001))
ncidx = ((nc.ageout>69.999) & (nc.ageout<70.001))
obsidx = ((obs.ageout>69.99) & (obs.ageout<70.01))
cols = ['ageout', 'ci_oc', 'ci_cv', 'ci_rc']
hi.loc[hiidx, cols]
med.loc[medidx, cols]
nc.loc[ncidx, cols]
lo.loc[loidx, cols]
obs.loc[obsidx, cols]
