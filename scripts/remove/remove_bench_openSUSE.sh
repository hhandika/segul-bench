#!/usr/bin/env fish

set INPUT_DIR "alignments/oliveros_2019_80p_trimmed"
set RM_TAXA_LIST "Xenicus_gilviventris Xenops_minutus Zeledonia_coronata Zosterops_everetti"
set OUTPUT_DIR "remove_results"
set OUTPUT_LOG "data/remove_bench.txt"
set CORES 24


# Get system information
uname -r | tee $OUTPUT_LOG

if test -f $OUTPUT_LOG
rm $OUTPUT_LOG
end

if [ -d $OUTPUT_DIR ]
rm -r $OUTPUT_DIR
end

echo -e "Warming up..."

segul remove -i $INPUT_DIR/*.nex -f nexus --id $RM_TAXA_LIST -o $OUTPUT_DIR --output-format phylip

echo -e "\nBenchmarking Alignment Taxon Removal"

echo "Benchmarking SEGUL Remove" | tee -a $OUTPUT_LOG

for i in (seq 10)
rm -r $OUTPUT_DIR;
echo ""
echo "Iteration $i"
# We append the STDERR to the log file because gnu time output to STDERR
env time -f "%E %M %P" segul remove -i $INPUT_DIR/*.nex -f nexus --id $RM_TAXA_LIST -o $OUTPUT_DIR --output-format phylip 2>> $OUTPUT_LOG;
end

### SEGUL ignore datatype ###

echo -e "\nBenchmarking SEGUL ignore datatype" | tee -a $OUTPUT_LOG
for i in (seq 10)
rm -r $OUTPUT_DIR;
echo ""
echo "Iteration $i"
# We append the STDERR to the log file because gnu time output to STDERR
env time -f "%E %M %P" segul remove -i $INPUT_DIR/*.nex -f nexus --id $RM_TAXA_LIST -o $OUTPUT_DIR --output-format phylip --datatype ignore 2>> $OUTPUT_LOG;
end

#### AMAS ####
if [ -d $OUTPUT_DIR ]
rm -r $OUTPUT_DIR
end


echo -e "\nWarming up..."

AMAS.py remove -i $INPUT_DIR/*.nex -f phylip -d dna -l $PARTITION -d dna -u phylip -c $CORES

echo -e "\nBenchmarking AMAS" | tee -a $OUTPUT_LOG

for i in (seq 10)

echo ""
echo "Iteration $i"
env time -f "%E %M %P" AMAS.py remove -i $INPUT_DIR/*.nex -f phylip -d dna -l $PARTITION -u phylip --remove-empty -c $CORES 2>> $OUTPUT_LOG;
end

### AMAS single core ###

echo -e "\nBenchmarking AMAS Single CORE" | tee -a $OUTPUT_LOG

for i in (seq 10)
rm alignments/Onn_2020_all_combined//alignment_all-combined_*
echo ""
echo "Iteration $i"
env time -f "%E %M %P" AMAS.py split -i $INPUT_FILE -f phylip -d dna -l $PARTITION -u phylip --remove-empty 2>> $OUTPUT_LOG;
end

### AMAS with empty sequences ###

echo -e "\nBenchmarking AMAS KEEP EMPTY" | tee -a $OUTPUT_LOG

for i in (seq 10)
rm alignments/Onn_2020_all_combined//alignment_all-combined_*
echo ""
echo "Iteration $i"
env time -f "%E %M %P" AMAS.py split -i $INPUT_FILE -f phylip -d dna -l $PARTITION -u phylip -c $CORES 2>> $OUTPUT_LOG;
end

### Final touches ###

set Date (date +%F)

set fname "split_bench_raw_OpenSUSE_$Date.txt"

mv $OUTPUT_LOG data/$fname

### Cleaning up ###
if [ -d $OUTPUT_DIR ]
rm -r $OUTPUT_DIR
end

rm *.log
rm alignments/Onn_2020_all_combined/alignment_all-combined_*

### Push to Github ###

git add -A && git commit -m "Add concatenation benchmark" && git push

