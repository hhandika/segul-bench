#!/usr/bin/env fish

set INPUT_DIRS "alignments/esselstyn_2021_nexus_trimmed" "alignments/oliveros_2019_80p_trimmed" "alignments/jarvis_2014_uce_filtered_w_gator" "alignments/chan_2020_loci/"
set OUTPUT_DIR "concat_results"
set OUTPUT_LOG "data/concat_bench.txt"
set CORES 24



# Remove existing log file
if test -f $OUTPUT_LOG
rm $OUTPUT_LOG
end

# Get system information
lscpu | egrep 'Model name|Thread|CPU\(s\)|Core\(s\) per socket' | tee -a $OUTPUT_LOG
uname -r  | tee -a $OUTPUT_LOG

#### AMAS ####

if [ -d $OUTPUT_DIR ]
rm -r $OUTPUT_DIR
end


echo -e "\nWarming up..."

AMAS.py concat -i alignments/esselstyn_2021_nexus_trimmed/*.nex -f nexus -d dna -c $CORES

echo -e "\nBenchmarking AMAS" | tee -a $OUTPUT_LOG

for dir in $INPUT_DIRS
echo ""
echo -e "\nDataset path: $dir" | tee -a $OUTPUT_LOG
for i in (seq 10)
rm concatenated.out && rm partitions.txt
echo ""
echo "Iteration $i"
env time -f "%E %M %P" AMAS.py concat -i $dir/*.nex -f nexus -d dna -c $CORES --check-align 2>> $OUTPUT_LOG;
end
end

### Final touches ###

set Date (date +%F)

set fname "concat_bench_raw_WSL_AMAS_checkalign_$Date.txt"

mv $OUTPUT_LOG data/$fname

### Cleaning up ###

rm -r $OUTPUT_DIR
rm *.log
rm concatenated.out && rm partitions.txt

### Push to Github ###

git add -A && git commit -m "Add missing AMAS check-align benchmark" && git push

