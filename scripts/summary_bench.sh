#!/usr/bin/env fish

set INPUT_DIRS "alignments/esselstyn_2021_nexus_trimmed" "alignments/oliveros_2019_80p_trimmed" "alignments/jarvis_2014_uce_filtered_w_gator"
set OUTPUT_DIR "summary_results"
set OUTPUT_LOG "data/summary_bench.txt"
set CORES "24"


# Get system information
uname -v >> $OUTPUT_LOG

if test -f $OUTPUT_LOG
rm $OUTPUT_LOG
end

if [ -d $OUTPUT_DIR ]
rm -r $OUTPUT_DIR
end

echo -e "Warming up..."

segul summary -d alignments/esselstyn_2021_nexus_trimmed -f nexus -o $OUTPUT_DIR

echo -e "\nBenchmarking Summary Stats"

echo "Benchmarking SEGUL" | tee -a $OUTPUT_LOG
for dir in $INPUT_DIRS
echo ""
echo "Dataset path: $dir" | tee -a $OUTPUT_LOG
for i in (seq 10)
rm -r $OUTPUT_DIR;
echo ""
echo "Iteration $i"
# We append the STDERR to the log file because gnu time output to STDERR
env time -f "%E %M %P" segul summary -i $dir/*.nex -f nexus -o $OUTPUT_DIR 2>> $OUTPUT_LOG;
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
for i in (seq 10)
rm summary.txt
echo ""
echo "Iteration $i"
env time -f "%E %M %P" AMAS.py summary -i $dir/*.nex -f nexus -d dna -c $CORES 2>> $OUTPUT_LOG;
end
end

#### Phyluce ####

conda activate phyluce

if [ -d $OUTPUT_DIR ]
rm -r $OUTPUT_DIR
end

echo -e "\nWarming up..."

phyluce_align_get_align_summary_data --alignments alignments/esselstyn_2021_nexus_trimmed --core $CORES

echo -e "\nBenchmarking Phyluce" | tee -a $OUTPUT_LOG

for dir in $INPUT_DIRS
echo ""
echo "Dataset path: $dir" | tee -a $OUTPUT_LOG
for i in (seq 10)
echo ""
echo "Iteration $i"
env time -f "%E %M %P" phyluce_align_get_align_summary_data --alignments $dir --core $CORES 2>> $OUTPUT_LOG;
end
end

### Final touches ###

set Date (date +%F)

set fname "summary_bench_raw_PC_$Date.txt"

mv $OUTPUT_LOG data/$fname

### Cleaning up ###

rm -r $OUTPUT_DIR
rm *.log
rm summary.txt

### Push to Github ###

git add -A && git commit -m "Add summary benchmark" && git push

