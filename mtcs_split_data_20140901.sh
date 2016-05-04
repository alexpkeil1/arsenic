#!/bin/bash
######################################################################################################################
# Author: Alex Keil
# Program: mtcs_split_data_20140901.sh
# Language: bash - available on UNIX-alike machines only (OSX, Linux)
# Date: Monday, September 1, 2014 at 2:48:14 PM
# Project: MT copper smelter data
# Tasks:
# Data in: /Users/akeil/EpiProjects/MT_copper_smelters/data/raw/TIMEEXP2.DAT
# Data out: /Users/akeil/EpiProjects/MT_copper_smelters/data/mtcs_longitudinal.txt
#           /Users/akeil/EpiProjects/MT_copper_smelters/data/mtcs_demographic.txt
# Description:
# Keywords:
# Released under the GNU General Public License: http://www.gnu.org/copyleft/gpl.html
#
#####################################################################################################################

cd /Users/akeil/EpiProjects/MT_copper_smelters/data/raw
#create temporary working copy
#head -800 TIMEEXP2.DAT > testdat.dat
#awk 'NR % 80 != 1' testdat.dat > testdat2.dat

#echo 'smid   dob       hiredate  termdate  dlvs      start_fu  dlo         icd   vstat asex  so2ex indvar' > ../mtcs_demographic.txt
awk 'NR == 1 || NR % 80 == 1' TIMEEXP2.DAT > ../mtcs_demographic.txt

#echo "smid   age   aslt   asmd   ashi   asuk   so2lt  so2md  so2hi  so2uk  empdur   cumas   cumso2  maxas maxso2" > ../mtcs_longitudinal.txt
awk 'NR % 80 != 1' TIMEEXP2.DAT > ../mtcs_longitudinal.txt