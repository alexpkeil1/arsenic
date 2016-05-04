#!/bin/sh

cd

cd /Users/akeil/EpiProjects/MT_copper_smelters/code/kd_temp
mv *sas *R /.Trashes/

# Data cleaning
# cp /Users/akeil/EpiProjects/MT_copper_smelters/code/mtcs_apply_rates_2014916.sas .
# cp /Users/akeil/EpiProjects/MT_copper_smelters/code/mtcs_import_20140828.sas .
# cp /Users/akeil/EpiProjects/MT_copper_smelters/code/mtcs_lagdata_201492.sas .
# cp /Users/akeil/EpiProjects/MT_copper_smelters/code/mtcs_maketableddata_201498.sas .
# cp /Users/akeil/EpiProjects/MT_copper_smelters/code/mtcs_cleaning_20140828.sas .
# cp /Users/akeil/EpiProjects/MT_copper_smelters/code/mtcs_logicchecks_20140901.sas .


# cp /Users/akeil/EpiProjects/MT_copper_smelters/code/mtcs_modelcompare_20141008.sas .
# cp /Users/akeil/EpiProjects/MT_copper_smelters/code/mtcs_table1_20141017.sas .

# Standard g-formula
# cp /Users/akeil/EpiProjects/MT_copper_smelters/code/mtcs_gformula_20140908.sas .
# cp /Users/akeil/EpiProjects/MT_copper_smelters/code/mtcs_gformula_mksurv_20150331.sas .
# cp /Users/akeil/EpiProjects/MT_copper_smelters/code/GFORMULA_kmpics_2014926.R .


# bootstrap
 cp /Users/akeil/EpiProjects/MT_copper_smelters/code/mtcs_gformula_boot_2015421.sas .
 cp /Users/akeil/EpiProjects/MT_copper_smelters/code/mtcs_gformula_mksurv_20150331_batch.sas .
 cp /Users/akeil/EpiProjects/MT_copper_smelters/code/mtcs_gformula_20140908_batch.sas .
 cp /Users/akeil/EpiProjects/MT_copper_smelters/code/mtcs_batch_boots.sh .
 cp /Users/akeil/EpiProjects/MT_copper_smelters/code/mtcs_mk_boot_survdata.sas .

for f in *.sas; 
 do  
 perl -p -i -e 's/Z\:/\/nas02\/home\/a\/k\/akeil/g' $f 
 perl -p -i -e 's/^DM.*//g' $f 
done

#for f in *.R; 
# do  
# perl -p -i -e 's/\~\/EpiProjects/\/nas02\/home\/a\/k\/akeil\/EpiProjects/g' $f 
#done
