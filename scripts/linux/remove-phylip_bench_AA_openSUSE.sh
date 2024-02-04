#!/usr/bin/env fish
set INPUT_DIRS "alignments/shen_2018_phylip/" "alignments/wu_2018_phylip/"

set RM_TAXA_LIST "Alloascoidea_hylecoeti Ambrosiozyma_kashinagacola Ambrosiozyma_monospora" \
"AILUR_MEL ANOLI_CAR BALAE_ACU"

set OUTPUT_DIR "remove_results"
set OUTPUT_LOG "data/remove_bench_aa.txt"
set CORES 24
set NUM_ITERATIONS 5

# Remove existing log dir
if test -f $OUTPUT_LOG
rm $OUTPUT_LOG
end

# Get system information
lscpu | egrep 'Model name|Thread|CPU\(s\)|Core\(s\) per socket' | tee -a $OUTPUT_LOG
uname -r  | tee -a $OUTPUT_LOG

# Get segul version
segul -V | tee -a $OUTPUT_LOG

if [ -d $OUTPUT_DIR ]
rm -r $OUTPUT_DIR
end

echo -e "Warming up..."

segul sequence remove -i alignments/shen_2018_phylip/*.phy -f phylip --id $RM_TAXA_LIST[1] --datatype aa -o $OUTPUT_DIR --output-format phylip

echo -e "\nBenchmarking Alignment Taxon Removal"

echo "Benchmarking SEGUL Remove" | tee -a $OUTPUT_LOG
for dir in $INPUT_DIRS
echo ""
echo "Dataset path: $dir" | tee -a $OUTPUT_LOG
set index (contains -i -- $dir $INPUT_DIRS)
for i in (seq $NUM_ITERATIONS)
rm -r $OUTPUT_DIR;
echo ""
echo "Iteration $i"
# We append the STDERR to the log dir because gnu time output to STDERR
env time -f "%E %M %P" segul sequence remove -i $dir/*.phy -f phylip --id $RM_TAXA_LIST[$index] --datatype aa -o $OUTPUT_DIR --output-format phylip 2>> $OUTPUT_LOG;
end
end

### SEGUL ignore datatype ###

echo -e "\nBenchmarking SEGUL ignore datatype" | tee -a $OUTPUT_LOG
for dir in $INPUT_DIRS
echo ""
echo "Dataset path: $dir" | tee -a $OUTPUT_LOG
set index (contains -i -- $dir $INPUT_DIRS)
for i in (seq $NUM_ITERATIONS)
rm -r $OUTPUT_DIR;
echo ""
echo "Iteration $i"
# We append the STDERR to the log dir because gnu time output to STDERR
env time -f "%E %M %P" segul sequence remove -i $dir/*.phy -f phylip --id $RM_TAXA_LIST[$index] -o $OUTPUT_DIR --output-format phylip --datatype ignore 2>> $OUTPUT_LOG;
end
end

#### AMAS ####
if [ -d $OUTPUT_DIR ]
rm -r $OUTPUT_DIR
end



echo -e "\nWarming up..."

AMAS.py remove -i alignments/shen_2018_phylip/*.phy -x $RM_TAXA_LIST[0] -f phylip -d aa -u phylip -c $CORES

echo -e "\nBenchmarking AMAS" | tee -a $OUTPUT_LOG
for dir in $INPUT_DIRS
echo ""
echo "Dataset path: $dir" | tee -a $OUTPUT_LOG
set index (contains -i -- $dir $INPUT_DIRS)
for i in (seq $NUM_ITERATIONS)
rm reduced*
echo ""
echo "Iteration $i"
env time -f "%E %M %P" AMAS.py remove -i $dir/*.phy -x $RM_TAXA_LIST[$index] -f phylip -d aa -u phylip -c $CORES 2>> $OUTPUT_LOG;
end
end

### AMAS with empty sequences ###

echo -e "\nBenchmarking AMAS (check align)" | tee -a $OUTPUT_LOG
for dir in $INPUT_DIRS
echo ""
echo "Dataset path: $dir" | tee -a $OUTPUT_LOG
set index (contains -i -- $dir $INPUT_DIRS)
for i in (seq $NUM_ITERATIONS)
rm reduced*
echo ""
echo "Iteration $i"
env time -f "%E %M %P" AMAS.py remove -i $dir/*.phy -x $RM_TAXA_LIST[$index] -f phylip -d aa -u phylip --check-align -c $CORES 2>> $OUTPUT_LOG;
end
end

### Final touches ###

set Date (date +%F)

set fname "remove-phylip_bench_raw_AA_OpenSUSE_$Date.txt"

mv $OUTPUT_LOG data/$fname

### Cleaning up ###
if [ -d $OUTPUT_DIR ]
rm -r $OUTPUT_DIR
end

rm *.log
rm reduced*
