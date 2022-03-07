#!/usr/bin/env fish

set INPUT_DIRS "alignments/esselstyn_2021_nexus_trimmed" "alignments/oliveros_2019_80p_trimmed" "alignments/jarvis_2014_uce_filtered_w_gator"
set OUTPUT_DIR "segul_results"
set OUTPUT_LOG "data/segul_bench.txt"


if test -f $OUTPUT_LOG
rm $OUTPUT_LOG
end

if [ -d $OUTPUT_DIR ]
rm -r $OUTPUT_DIR
end

echo -e "Warming up..."

segul concat -d alignments/esselstyn_2021_nexus_trimmed -f nexus -o $OUTPUT_DIR -F phylip

echo -e "\nBenchmarking Alignment Concatenation"

### SEGUL STABLE ###

echo -e "\nBenchmarking SEGUL" | tee -a $OUTPUT_LOG
for dir in $INPUT_DIRS
echo ""
echo "Dataset path: $dir" | tee -a $OUTPUT_LOG
for i in (seq 5)
rm -r $OUTPUT_DIR;
echo ""
echo "Iteration $i"
# We append the STDERR to the log file because gnu time output to STDERR
env time -f "%E %M %P" segul concat -d $dir -f nexus -o $OUTPUT_DIR -F phylip 2>> $OUTPUT_LOG;
end
end


#### SEGUL DEV ####
echo -e "\nBenchmarking SEGUL" | tee -a $OUTPUT_LOG
for dir in $INPUT_DIRS
echo ""
echo "Dataset path: $dir" | tee -a $OUTPUT_LOG
for i in (seq 5)
rm -r $OUTPUT_DIR;
echo ""
echo "Iteration $i"
# We append the STDERR to the log file because gnu time output to STDERR
env time -f "%E %M %P" segul-dev concat -d $dir -f nexus -o $OUTPUT_DIR -F phylip 2>> $OUTPUT_LOG;
end
end

### Final touches ###

set Date (date +%F)

set fname "segul_bench_raw_$Date.txt"

mv $OUTPUT_LOG data/$fname

### Cleaning up ###

rm -r $OUTPUT_DIR
rm *.log

### Push to Github ###

git add -A && git commit -m "Add concatenation benchmark" && git push

