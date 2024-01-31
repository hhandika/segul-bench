#!/usr/bin/env fish

set INPUT_DIRS "alignments/esselstyn_2021_nexus_trimmed" "alignments/oliveros_2019_80p_trimmed" "alignments/jarvis_2014_uce_filtered_w_gator" "alignments/chan_2020_loci/"
set OUTPUT_DIR "summary_results"
set OUTPUT_LOG "data/summary_bench.txt"
set CORES 24
set NUM_ITERATIONS 5

git pull

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

segul align summary -i alignments/esselstyn_2021_nexus_trimmed/*.nex -f nexus -o $OUTPUT_DIR

echo -e "\nBenchmarking Summary Stats"

echo "Benchmarking SEGUL" | tee -a $OUTPUT_LOG
for dir in $INPUT_DIRS
echo ""
echo "Dataset path: $dir" | tee -a $OUTPUT_LOG
for i in (seq $NUM_ITERATIONS)
rm -r $OUTPUT_DIR;
echo ""
echo "Iteration $i"
# We append the STDERR to the log file because gnu time output to STDERR
env time -f "%E %M %P" segul align summary -i $dir/*.nex -f nexus -o $OUTPUT_DIR 2>> $OUTPUT_LOG;
end
end

#### AMAS ####

if [ -d $OUTPUT_DIR ]
rm -r $OUTPUT_DIR
end

echo -e "\nWarming up..."

AMAS.py summary -i alignments/esselstyn_2021_nexus_trimmed/*.nex -f nexus -d dna -c $CORES

echo -e "\nBenchmarking AMAS" | tee -a $OUTPUT_LOG

for dir in $INPUT_DIRS
echo ""
echo "Dataset path: $dir" | tee -a $OUTPUT_LOG
for i in (seq $NUM_ITERATIONS)
rm summary.txt
echo ""
echo "Iteration $i"
env time -f "%E %M %P" AMAS.py summary -i $dir/*.nex -f nexus -d dna -c $CORES 2>> $OUTPUT_LOG;
end
end

### Final touches ###

set Date (date +%F)

set fname "summary_bench_raw_openSUSE_$Date.txt"

mv $OUTPUT_LOG data/$fname

### Cleaning up ###

rm -r $OUTPUT_DIR
rm *.log
rm summary.txt
