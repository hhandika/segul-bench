#!/usr/bin/env fish

set INPUT_FILE "alignments/chan_2020_all_combined/alignment_all-combined.phy"
set PARTITION "alignments/chan_2020_all_combined/partitions_all-combined.txt"
set OUTPUT_DIR "split_results"
set OUTPUT_LOG "data/split_bench.txt"
set AMAS_OUTPUT "alignments/chan_2020_all_combined/alignment_all-combined_*"
set CORES 24
set NUM_ITERATIONS 5

# Remove existing log file
if test -f $OUTPUT_LOG
rm $OUTPUT_LOG
end

# Get system information
lscpu | egrep 'Model name|Thread|CPU\(s\)|Core\(s\) per socket' | tee -a $OUTPUT_LOG
uname -r  | tee -a $OUTPUT_LOG

# Get segul version
segul -V | tee -a $OUTPUT_LOG

# Clean unnecessary files
if test -f $OUTPUT_LOG
rm $OUTPUT_LOG
end

if [ -d $OUTPUT_DIR ]
rm -r $OUTPUT_DIR
end

echo -e "Warming up..."

segul align split -i $INPUT_FILE -f phylip -I $PARTITION -o $OUTPUT_DIR --output-format phylip

echo -e "\nBenchmarking Alignment Splitting"

echo "Benchmarking SEGUL" | tee -a $OUTPUT_LOG
echo "Dataset path: $INPUT_FILE" | tee -a $OUTPUT_LOG
for i in (seq $NUM_ITERATIONS)
rm -r $OUTPUT_DIR;
echo ""
echo "Iteration $i"
# We append the STDERR to the log file because gnu time output to STDERR
env time -f "%E %M %P" segul align split -i $INPUT_FILE -f phylip -I $PARTITION -p raxml -o $OUTPUT_DIR --output-format phylip 2>> $OUTPUT_LOG;
end

### SEGUL ignore datatype ###

echo -e "\nBenchmarking SEGUL ignore datatype" | tee -a $OUTPUT_LOG
echo "Dataset path: $INPUT_FILE" | tee -a $OUTPUT_LOG

for i in (seq $NUM_ITERATIONS)
rm -r $OUTPUT_DIR;
echo ""
echo "Iteration $i"
# We append the STDERR to the log file because gnu time output to STDERR
env time -f "%E %M %P" segul align split -i $INPUT_FILE -f phylip -I $PARTITION -p raxml -o $OUTPUT_DIR --output-format phylip --datatype ignore 2>> $OUTPUT_LOG;
end

#### AMAS ####
if [ -d $OUTPUT_DIR ]
rm -r $OUTPUT_DIR
end


echo -e "\nWarming up..."
AMAS.py split -i $INPUT_FILE -f phylip -d dna -l $PARTITION -d dna -u phylip -c $CORES

echo -e "\nBenchmarking AMAS (--remove-empty)" | tee -a $OUTPUT_LOG
echo "Dataset path: $INPUT_FILE" | tee -a $OUTPUT_LOG

for i in (seq $NUM_ITERATIONS)
rm alignments/chan_2020_all_combined/alignment_all-combined_*
echo ""
echo "Iteration $i"
env time -f "%E %M %P" AMAS.py split -i $INPUT_FILE -f phylip -d dna -l $PARTITION -u phylip --remove-empty -c $CORES 2>> $OUTPUT_LOG;
end

### AMAS with empty sequences ###

echo -e "\nBenchmarking AMAS KEEP EMPTY" | tee -a $OUTPUT_LOG
echo "Dataset path: $INPUT_FILE" | tee -a $OUTPUT_LOG

for i in (seq $NUM_ITERATIONS)
rm alignments/chan_2020_all_combined/alignment_all-combined_*
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
rm alignments/chan_2020_all_combined/alignment_all-combined_*

### Push to Github ###

git add -A && git commit -m "Add concatenation benchmark" && git push

