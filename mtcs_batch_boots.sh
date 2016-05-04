#!/bin/sh

path=/lustre/scr/a/k/akeil/arsenic/boots
#path=/netscr/akeil/arsenic/boots
#path=/Users/akeil/EpiProjects/MT_copper_smelters/code/boots/

mkdir $path

#number of iterations per program
j=50
#number of total programs
n=10

#starting program
st=1

#basename of file
basename=mtcs_gformula_20140908_batch
bootname=mtcs_gformula_boot_2015421
compname=mtcs_gformula_mksurv_20150331_batch
cd $path
for((i=$st;i<=$n;i++))
do
	mkdir $i
	cp ../$bootname.sas ${bootname}_$i.sas
	find $path/${bootname}_$i.sas -type f | xargs perl -pi -e "s/root \= \;/root \= $i\;/g" ${bootname}_$i.sas
	find $path/${bootname}_$i.sas -type f | xargs perl -pi -e "s/niter\=3/niter\= $j/g" ${bootname}_$i.sas
done


for((i=$st;i<=$n;i++))
do
	cp ../$basename.sas ${basename}_$i.sas
	printf "st = $st, end = $j\t newfile: ${basename}_$i.sas\n "
	find $path/${basename}_$i.sas -type f | xargs perl -pi -e "s/mtcs.mtcs_an02/bootdata_$i/g" ${basename}_$i.sas
#    find $path/${basename}_$i.sas -type f | xargs perl -pi -e "s/obschanges/obschanges_$i/g" ${basename}_$i.sas
#    find $path/${basename}_$i.sas -type f | xargs perl -pi -e "s/natcourse/natcourse_$i/g" ${basename}_$i.sas
#    find $path/${basename}_$i.sas -type f | xargs perl -pi -e "s/noexposure/noexposure_$i/g" ${basename}_$i.sas
#    find $path/${basename}_$i.sas -type f | xargs perl -pi -e "s/hiexposure/hiexposure_$i/g" ${basename}_$i.sas
done

for((i=$st;i<=$n;i++))
do
	cp ../$compname.sas ${compname}_$i.sas
	printf "st = $st, end = $j\t newfile: ${compname}_$i.sas\n "
	find $path/${compname}_$i.sas -type f | xargs perl -pi -e "s/mtcs.mtcs_an02/bootdata_$i/g" ${compname}_$i.sas
#    find $path/${compname}_$i.sas -type f | xargs perl -pi -e "s/obschanges/obschanges_$i/g" ${compname}_$i.sas
#    find $path/${compname}_$i.sas -type f | xargs perl -pi -e "s/natcourse/natcourse_$i/g" ${compname}_$i.sas
#    find $path/${compname}_$i.sas -type f | xargs perl -pi -e "s/noexposure/noexposure_$i/g" ${compname}_$i.sas
#    find $path/${compname}_$i.sas -type f | xargs perl -pi -e "s/hiexposure/hiexposure_$i/g" ${compname}_$i.sas
done

declare -i CURRHR=$(date | sed 's/ /\n/g'| grep ":"|cut -d':' -f 1 | sed 's/^0*//')
declare -i CURRMIN=$(date | sed 's/ /\n/g'| grep ":"|cut -d':' -f 2 | sed 's/^0*//')
SUBTIME=$((CURRHR)):$((CURRMIN))

for((i=$st;i<=$n;i++))
do
	export SUBTIME=$((CURRHR)):$((CURRMIN))
    echo "$SUBTIME"
	bsub -q week -b $SUBTIME sas ${bootname}_$i.sas 
	# increment 30 minutes
	if [ $((CURRMIN + 29)) -ge 59 ]; then CURRHR=$(($CURRHR+1)); CURRMIN=$(($CURRMIN - 31));else CURRMIN=$(($CURRMIN +29)); fi;if [ $CURRHR -ge 24 ];then CURRHR=0; fi
	# increment 1:30 minutes
#	if [ $((CURRMIN + 29)) -ge 59 ]; then CURRHR=$(($CURRHR+2)); CURRMIN=$(($CURRMIN - 31));else CURRHR=$(($CURRHR+1));CURRMIN=$(($CURRMIN +29)); fi;if [ $CURRHR -ge 24 ];then CURRHR=0; fi
done


#after all programs are run, cd into boots directory and run this:
# for ((i=1;i<=10;i++)); do cd $i; mv * ../; cd ..; done;
# then run the mtcs_mk_boot_survdata.sas program to compile results