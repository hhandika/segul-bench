#!/usr/bin/env fish
set INPUT_DIRS "alignments/shen_2018_loci_aa/" "alignments/wu_2018_aa_loci/"

set RM_TAXA_LIST "Xenicus_gilviventris Xenops_minutus Zeledonia_coronata" \
"Zosterops_lateralis Zosterops_luteus Zosterops_montanus Zosterops_olivaceus" \
"Zosterops_palpebrosus Zosterops_villosus Zosterops_virescens Zosterops_vitensis" \
"Zosterops_vittatus Zosterops_vulcani Zosterops_wallacei Zosterops_atrirostris" \
"Zosterops_culicivorus Zosterops_flavifrons Zosterops_luteirostris Zosterops_maderaspatanus"

set OUTPUT_DIR "remove_results"
set OUTPUT_LOG "data/remove_bench.txt"
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

if test -f $OUTPUT_LOG
rm $OUTPUT_LOG
end

if [ -d $OUTPUT_DIR ]
rm -r $OUTPUT_DIR
end

echo -e "Warming up..."

segul sequence remove -i $INPUT_DIR/*.nex -f nexus --id $RM_TAXA_LIST -o $OUTPUT_DIR --output-format phylip

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
env time -f "%E %M %P" segul sequence remove -i $INPUT_DIR/*.nex -f nexus --id $RM_TAXA_LIST[$index] -o $OUTPUT_DIR --output-format phylip 2>> $OUTPUT_LOG;
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
env time -f "%E %M %P" segul sequence remove -i $INPUT_DIR/*.nex -f nexus --id $RM_TAXA_LIST[$index] -o $OUTPUT_DIR --output-format phylip --datatype ignore 2>> $OUTPUT_LOG;
end
end

#### AMAS ####
if [ -d $OUTPUT_DIR ]
rm -r $OUTPUT_DIR
end



echo -e "\nWarming up..."

AMAS.py remove -i $INPUT_DIR/*.nex -x $RM_TAXA_LIST -f nexus -d dna -u phylip -c $CORES

echo -e "\nBenchmarking AMAS" | tee -a $OUTPUT_LOG
for dir in $INPUT_DIRS
echo ""
echo "Dataset path: $dir" | tee -a $OUTPUT_LOG
set index (contains -i -- $dir $INPUT_DIRS)
for i in (seq $NUM_ITERATIONS)
rm reduced*
echo ""
echo "Iteration $i"
env time -f "%E %M %P" AMAS.py remove -i $INPUT_DIR/*.nex -x $RM_TAXA_LIST[$index] -f nexus -d dna -u phylip -c $CORES 2>> $OUTPUT_LOG;
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
env time -f "%E %M %P" AMAS.py remove -i $INPUT_DIR/*.nex -x $RM_TAXA_LIST[$index] -f nexus -d dna -u phylip --check-align -c $CORES 2>> $OUTPUT_LOG;
end
end

### Final touches ###

set Date (date +%F)

set fname "remove_bench_raw_OpenSUSE_$Date.txt"

mv $OUTPUT_LOG data/$fname

### Cleaning up ###
if [ -d $OUTPUT_DIR ]
rm -r $OUTPUT_DIR
end

rm *.log
rm reduced*
