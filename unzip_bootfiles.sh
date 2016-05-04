#  zip files on killdevil/kure (takes a while - add v for verbose)
#  keep only the bootstrap CI estimates and a smattering of the log files - saves ~15%
rm boots.tar.bz2
tar -cjvf boots.tar.bz2 boots --exclude=*[1-9].log --exclude=*course.sas7bdat --exclude=*exposure.sas7bdat  --exclude=*changes.sas7bdat  --exclude=*.sas --exclude=*.lst

cd /Users/akeil/EpiProjects/MT_copper_smelters/data
#  inspect contents (first 10 files)
tar -jtvf boots.tar.bz2 | head 
 
#  unzip all files into single nested folder
mkdir boots
cd boots
tar -xvf ../boots.tar.bz2  --strip-components 2
gunzip -f *


#or do this and then run 
#cd /lustre/scr/a/k/akeil/arsenic/boots
#for d in */
#do
#    dir=${d%*/}
#    #echo ${dir##*/}
#    ls $dir | head
#    mv $dir/*sas7bdat .
#done


# or an even better way:
# copy all files to boot directory in lustre!
cd /lustre/scr/a/k/akeil/arsenic/boots
#cd /netscr/akeil/arsenic/boots
for d in */
do
    dir=${d%*/}
    #ls $dir/*_$dir_[0-9]{,[0-9]}.sas7bdat | tail -n 1 #want these
    #ls $dir/*[a-z]_$dir.sas7bdat | head -n 1 #don't want these
    # mv $dir/* .
    #cp --update $dir/*[a-z]_[0-9]{,[0-9]}_[0-9]{,[0-9]}.sas7bdat /lustre/scr/a/k/akeil/arsenic/boots/.
    mv $dir/*[a-z]_[0-9]{,[0-9]}_[0-9]{,[0-9]}.sas7bdat /lustre/scr/a/k/akeil/arsenic/boots/.
done
cd /lustre/scr/a/k/akeil/arsenic/boots
ls -1 *[a-z]_[0-9]{,[0-9]}_[0-9]{,[0-9]}.sas7bdat | wc -l # count files in the directory (divide by 15 to get approx number of ints.)

#ls *_[0-9]{,[0-9]}_[0-9]{,[0-9]}.sas7bdat | tail -n 10 # want these
ls *[a-z]_[0-9]{[0-9],}_[0-9]{[0-9],}.sas7bdat | head -n 10 # want these
ls *[a-z]_[0-9]{,[0-9]}.sas7bdat # don't want these
#rm  *[a-z]_[0-9]{,[0-9]}.sas7bdat  # remove the unwanted ones








#had to make a couple of copies using this R code
#fls = c("cidata_age_lo_7_49.sas7bdat", "cidata_age_hi_7_49.sas7bdat", "cidata_age_med_7_49.sas7bdat", "cidata_age_nc_7_49.sas7bdat", "cidata_age_ne_7_49.sas7bdat", "cidata_age_obs_7_49.sas7bdat", "surv_lw_age_lo_7_49.sas7bdat", "surv_lw_age_hi_7_49.sas7bdat", "surv_lw_age_med_7_49.sas7bdat", "surv_lw_age_nc_7_49.sas7bdat", "surv_lw_age_ne_7_49.sas7bdat", "surv_lw_age_obs_7_49.sas7bdat", "surv_rw_age_lo_7_49.sas7bdat", "surv_rw_age_hi_7_49.sas7bdat", "surv_rw_age_med_7_49.sas7bdat", "surv_rw_age_nc_7_49.sas7bdat", "surv_rw_age_ne_7_49.sas7bdat", "surv_rw_age_obs_7_49.sas7bdat")
#fls2 = gsub("7_49", "7_48", fls)
#fls3 = gsub("7_49", "7_49", fls)
#fls3 = gsub("7_49", "7_50", fls)
  
#for(f in 1:length(fls)){
# cat('cp ', fls2[f], ' ', fls3[f], '\n')  
#}