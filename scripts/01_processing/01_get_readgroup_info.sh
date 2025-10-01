#!/bin/bash

# change directory
# This is where the raw fast files are. All of them are in the same folder 
cd fastq/

# create file with list of R1 samples. Data is paired end R1 and R2. 
# We only need to collect the read information once per sample. The read information is in both the R1 and R2 fastq files. 
ls -1 | grep _R1_ > R1Samples.txt

# loops through list 
touch sampleReadInfo.txt # creates an empty file
for sample in `cat R1Samples.txt`; do
    zcat ${sample} | head -1 >> sampleReadInfo.txt # read the first line of each R1 file
done;

# mv the files 
mv R1Samples.txt  ../scripts/01_processing/R1Samples.txt
mv sampleReadInfo.txt ../scripts/01_processing/sampleReadInfo.txt

cd ../scripts/01_processing/
paste -d "\t" R1Samples.txt sampleReadInfo.txt > sampleReadGroupInfo.txt # create sample info
rm R1Samples.txt
rm sampleReadInfo.txt