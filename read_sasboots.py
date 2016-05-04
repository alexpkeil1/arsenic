# -*- coding: utf-8 -*-
"""
Created on Sat Apr 23 14:24:40 2016

@author: akeil
@description: series of functions to handle bootstrap estimates from SAS
 programs using copper smelter data. Can either compile summaries
 from existing bootstrap files (where eachobserveration is the CI functions
 for a given age) or can create bootstrap CSV files and summarize those
"""

import sas7bdat as sas
import re
import numpy as np
import matplotlib.pyplot as plt
import scipy.stats as sci
import pandas as pd
import os


def summ_dat(datnm='', per=1):
    '''
    Read from sas created age-specific bootstrap files
    Print a table of results using bootstrap mean
     and percentile based confidence intervals.
    repeat over each intervention, generating intervention
     effect estimates
     
    Only works for age 70!
     
    Also plots kernel density of bootstrap estimates
    '''
    base = sas.SAS7BDAT(pth+"sbootage70ne.sas7bdat").to_data_frame(
           ).loc[:, ('ci_ac', 'ci_rc', 'ci_cv', 'ci_oc')]
    shortname = re.sub('sboot|\.sas7bdat','',datnm)
    dat = sas.SAS7BDAT(os.path.join(pth,datnm)).to_data_frame(
           ).loc[:, ('ci_ac', 'ci_rc', 'ci_cv', 'ci_oc')]
    p = [i for i in range(4)]
    if shortname != 'age70ne':
        f, ((p[0], p[1]), (p[2], p[3])) = plt.subplots(2, 2, 
                              sharex='col', sharey='row')
    xs = np.linspace(-0.1, 0.2, 301)
    for i, col in enumerate(dat.columns):
        dat['excess_' + col] = dat[col]-base[col]
        if shortname != 'age70ne':
            density  = sci.gaussian_kde(dat.loc[:,'excess_' + col])
            p[i].plot(xs, density(xs))
            p[i].set_title(shortname + ' excess_' + col)

    if shortname != 'age70ne':
        plt.show()

    fmt = '{:12} | {:9.1f} | {:9.1f} | {:9.1f} | {:9.1f}'
    print('\n')
    print('{:12} | {:^9} | {:^9} | {:^9} | {:^9} '.format(
          shortname, 'mean', "95% lower", "95% upper", 'sd'))

    for col in dat.columns:
        mn = dat.loc[:, col].nanmean(0)
        sd = dat.loc[:, col].nanstd(0)
        lci, uci = (np.nanpercentile(dat.loc[:, col], 2.5, 0),  
                    np.nanpercentile(dat.loc[:, col], 97.5, 0))
        print(fmt.format(col, mn*per, lci*per, uci*per, sd*per))


def print_boots(flstr='_ne_', dirnm='/tmp'):
    '''
    Plot bootstrap cumulative incidence functions for a given
    intervention
    '''
    fls = [f for f in os.listdir(dirnm) if ((
        str.find(f, flstr)>-1) & (str.find(f, 'surv')<0))]
    p = [i for i in range(4)]
    f, ((p[0], p[1]), (p[2], p[3])) = plt.subplots(2, 2, 
                             sharex='col')
    for fl in fls:
        dat = sas.SAS7BDAT(os.path.join(dirnm,fl)).to_data_frame()
        for i, ci in enumerate(['ci_ac', 'ci_rc', 'ci_cv', 'ci_oc']):
            p[i].plot(dat['ageout'], dat[ci])
            p[i].set_title(flstr.replace('_','') + ': ' + ci)
        #dat.close()
    plt.show()


def compile_boots(flstr = '_ne_', dirnm='/tmp', outfile=None, age=70):
    '''
    Compile a series of bootstrap CI data files (sas7bdat format)
    into a single DataFrame, possibly writing to a CSV file.
    Usage: 
    compile_boots(flstr = '_ne_', dirnm=ci_path, outfile=None, age=70)
    
    flstr = unique identifying struing in a file name that helps to 
      select a subset of datafiles in the directory dirnm
      (e.g. '_ne_')
    
    dirnm = directory in which bootstrap results are stored
    
    outfile = optional. If not set to None, then the name of a csv
     file to hold the output from this function
     
    age = age to define the cumulative incidence functions
    '''
    fls = [f for f in os.listdir(dirnm) if ((
        str.find(f, flstr)>-1) & (str.find(f, 'surv')<0))]
    dflist = []
    for fl in fls:
        print('reading:', fl)
        with sas.SAS7BDAT(os.path.join(dirnm,fl)) as dat:
            dtemp = dat.to_data_frame()
            dtemp['file'] = '_'.join(re.split('[_\.]', fl)[3:5])
            dflist.append(dtemp[(dtemp.ageout >= age) &
                                (dtemp.ageout < (age+.5))])
    td = pd.concat(x.head(1) for x in dflist)[
                ['file', 'ageout','ci_ac', 'ci_rc', 'ci_cv', 'ci_oc']]
    if outfile is not None:
        td.to_csv(outfile, index=False)
    return(td)
    
def getnames(flname):
    with sas.SAS7BDAT(flname) as f:
        return [ l for l in f if (type(l[0]) is str)][0]


def compile_boots2(flstr = '_ne_', dirnm='/tmp', outfile=None, age=70):
    '''
    Compile a series of bootstrap CI data files (sas7bdat format)
    into a single DataFrame, possibly writing to a CSV file.
    Usage: 
    compile_boots(flstr = '_ne_', dirnm=ci_path, outfile=None, age=70)
    
    flstr = unique identifying struing in a file name that helps to 
      select a subset of datafiles in the directory dirnm
      (e.g. '_ne_')
    
    dirnm = directory in which bootstrap results are stored
    
    outfile = optional. If not set to None, then the name of a csv
     file to hold the output from this function
     
    age = age to define the cumulative incidence functions
    '''
    fls = [f for f in os.listdir(dirnm) if ((
        str.find(f, flstr)>-1) & (str.find(f, 'surv')<0))]
    dflist = []
    colnames = {}  # dictionary of column names for specific file types
    for fl in fls:
        #print('reading:', fl)
        if fl[0:2] not in colnames:
            colnames[fl[0:2]] = getnames(os.path.join(dirnm,fl))
        nms = colnames[fl[0:2]]
        with sas.SAS7BDAT(os.path.join(dirnm,fl)) as f:
            for l in f:
                if (type(l[0]) is not str) and (l[0] >= age):
                    break
        srs = pd.DataFrame([l], columns=nms)        
        srs['file'] = '_'.join(re.split('[_\.]', fl)[3:5])
        dflist.append(srs)
    td = pd.concat(x for x in dflist)[
                ['file', 'ageout','ci_ac', 'ci_rc', 'ci_cv', 'ci_oc']]
    if outfile is not None:
        td.to_csv(outfile, index=False)
    return(td)    

def boot_pyprocess(datfile=None, reffile=None):
    '''
    Workhorse function for intervention effects for each
     bootstrap iteration
    return DataFrame with bootstrap samples + excess
    '''
    dat = pd.read_csv(datfile).loc[:,
            ('file', 'ci_ac', 'ci_rc', 'ci_cv', 'ci_oc')].set_index(['file'])
    ref = pd.read_csv(reffile).loc[:,
            ('file', 'ci_ac', 'ci_rc', 'ci_cv', 'ci_oc')].set_index(['file'])
    if datfile.find("_obs_")<0:
        for col in ['ci_ac', 'ci_rc', 'ci_cv', 'ci_oc']:
            dat['excess_' + col] = dat[col]-ref[col]
        for col in ['ci_ac', 'ci_rc', 'ci_cv', 'ci_oc']:
            dat['ratio_' + col] = (dat[col]/ref[col]) # to fix the auto-multiplication in the next step
    return dat


def boot_summarize(datfile=None, reffile=None, outfile=None, outint=None, mult=1000):
    '''
    Workhorse function for summarizing bootstrap sample data
     created by the boot_pyprocess function
    '''
    dat = boot_pyprocess(datfile=datfile,
                         reffile=reffile)
    outdat = pd.DataFrame(columns=['mn', 'uci', 'lci', 'sd', 'N', 'summary'], 
                          index=dat.columns)
    for col in dat.columns:
        if col.find('ratio') > -1: remult = 1/1000
        else: remult = 1
        outdat.loc[col, 'mn'] = np.nanmean(dat.loc[:, col], 0)*mult*remult
        outdat.loc[col, 'sd'] = np.nanstd(dat.loc[:, col], 0)*mult*remult
        outdat.loc[col, 'N'] = np.size(dat.loc[:, col], 0)
        outdat.loc[col, 'lci'], outdat.loc[col, 'uci'] = (
                    np.nanpercentile(dat.loc[:, col], 2.5, 0)*mult*remult,
                    np.nanpercentile(dat.loc[:, col], 97.5, 0)*mult*remult)
        outdat.loc[col, 'summary'] = (
             '{:4.1f} ({:4.1f}, {:4.1f}) '.format(
             outdat.loc[col, 'mn'],
             outdat.loc[col, 'lci'],
             outdat.loc[col, 'uci']
             ))
    if outfile is not None:
        outdat.to_csv(outfile, index=True)
    if outint is not None:
        dat.to_csv(outint, index=True)
    return(outdat)


# PRIMARY USER FUNCTIONS

def compile_all_boots(indir, outdir, ages=[70]):
    '''
    Compile a series of bootstrap CI data files (sas7bdat format)
    into a single DataFrame, possibly writing to a CSV file.
    Usage:
    compile_boots(flstr = '_ne_', dirnm=ci_path, outfile=None, age=70)
    
    flstr = unique identifying struing in a file name that helps to
      select a subset of datafiles in the directory dirnm
      (e.g. '_ne_')
    
    dirnm = directory in which bootstrap results are stored
    
    outdir = directory in which summary output results are stored
     
    ages = ages to define the cumulative incidence functions
    '''
    flstrs = ['_nc_', '_ne_', '_lo_', '_med_', '_hi_', '_obs_']
    for flstr in flstrs:
        for age in ages:
            outfile = os.path.join(outdir, 'cidat' + flstr + str(age) + '.csv')
            if age > 70:
                compile_boots(flstr, indir, outfile, age)
            else:
                compile_boots2(flstr, indir, outfile, age)
    



def boot_summarize_all(indir=None, outdir=None, ages=[70], outintdir=None):
    '''
    read in existing bootstrap files for a given set of ages
    and output a file/print results for intervention effects
    '''
    flstrs = ['_nc_', '_ne_', '_lo_', '_med_', '_hi_', '_obs_'] 
    for age in ages:
        reffile = os.path.join(indir, 'cidat' + '_ne_' + str(age) + '.csv')
        for flstr in flstrs:
            print(flstr)
            datfile = os.path.join(indir, 'cidat' 
                + flstr + str(age) + '.csv')
            if outintdir is not None:
                oifile = os.path.join(indir, 'cidat' + '_all_'
                + flstr + str(age) + '.csv')
            else:
                oifile = None
            if outdir is None:
                ret = boot_summarize(datfile=datfile, reffile=reffile,
                                     mult=1000)
                print(ret)
            if outdir is not None:
                of = os.path.join(outdir, 'cidat' +
                            '_summary_' + flstr + str(age) + '.csv')
                ret = boot_summarize(datfile=datfile, reffile=reffile, 
                                     outfile=of, outint=oifile, mult=1000)
                print(ret)



if __name__ == '__main__':
    pth = '/Users/akeil/EpiProjects/MT_copper_smelters/data/out/all_withmid/'
    dtnms = ["sbootage70obs.sas7bdat",
             "sbootage70ne.sas7bdat",
             "sbootage70nc.sas7bdat",
             "sbootage70lo.sas7bdat",
             "sbootage70mid.sas7bdat",
             "sbootage70hi.sas7bdat"]


    ci_path = os.path.join(pth, "samples")
    # print_boots(flstr = '_ne_', dirnm=ci_path)
    # print_boots(flstr = '_hi_', dirnm=ci_path)

    # tmpfile = '/Users/akeil/temp/cidat_obs_70.csv'
    # compile_boots(flstr = '_obs_', dirnm=ci_path, outfile=tmpfile, age=70)

    # create csv files with bootstrap estimates at age 70
    # compile_all_boots(indir = ci_path, outdir = '/Users/akeil/temp', ages=[70])

    # example with single intervention
    # reffile = os.path.join('/Users/akeil/temp/', 'cidat' + '_ne_' + str(70) + '.csv')
    # bootfile = os.path.join('/Users/akeil/temp/', 'cidat' + '_hi_' + str(70) + '.csv')

    # dat = boot_pyprocess(datfile=bootfile, reffile=reffile)
    # boot_summarize(datfile=bootfile, reffile=reffile, outfile="/Users/akeil/temp/pysumm.csv")

    # PRIMARY USER FUNCTION EXAMPLES
    # example with all files
    ages = [50, 70]
    compile_all_boots(ci_path, outdir='/Users/akeil/temp/', ages=ages)
    boot_summarize_all(indir='/Users/akeil/temp/', outdir='/Users/akeil/temp/',
                       outintdir='/Users/akeil/temp/', ages=ages)
