# -*- coding: utf-8 -*-
"""
Created on Sun Apr 24 15:04:04 2016

@author: akeil
bsub -q week -M 48 -oo bootput.txt python3 read_sasboots_kd.py
"""
import read_sasboots as rs
import os

#pth = '/Users/akeil/EpiProjects/MT_copper_smelters/data/out/all_withmid/'
ci_path = '/lustre/scr/a/k/akeil/arsenic/boots'
outpath = '/nas02/home/a/k/akeil/EpiProjects/MT_copper_smelters/data/out_kd'

print('Total files:'+ str(len(os.listdir(ci_path))))

# priorize age 70
ages = [70]
#rs.compile_all_boots(ci_path, outdir=outpath, ages=ages) 
rs.boot_summarize_all(indir=outpath, outdir=outpath, outintdir=outpath, ages=ages)


ages = [60]
#rs.compile_all_boots(ci_path, outdir=outpath, ages=ages) 
rs.boot_summarize_all(indir=outpath, outdir=outpath, outintdir=outpath, ages=ages)

ages = [80]
#rs.compile_all_boots(ci_path, outdir=outpath, ages=ages) 
rs.boot_summarize_all(indir=outpath, outdir=outpath, outintdir=outpath, ages=ages)

ages = [89]
#rs.compile_all_boots(ci_path, outdir=outpath, ages=ages) 
rs.boot_summarize_all(indir=outpath, outdir=outpath, outintdir=outpath, ages=ages)

ages = [50]
#rs.compile_all_boots(ci_path, outdir=outpath, ages=ages) 
rs.boot_summarize_all(indir=outpath, outdir=outpath, outintdir=outpath, ages=ages)
