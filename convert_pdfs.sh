#!/bin/sh
cd /Users/akeil/EpiProjects/MT_copper_smelters/output/images/

for f in deaths*
do
echo $f
convert  -density 320 $f -background white -alpha remove postprocess/$f.png
done


for f in km*
do
echo $f
convert  -density 320 $f -background white -alpha remove postprocess/$f.png
done


