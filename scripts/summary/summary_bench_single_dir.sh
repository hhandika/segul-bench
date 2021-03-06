#!/usr/bin/env fish

set INPUT_DIR "shrew-nexus-clean-trimmed/"
set OUTPUT_DIR "summary_results"
set OUTPUT_LOG "summary_bench.log"
set CORES "24"

if test -f $OUTPUT_LOG
    rm $OUTPUT_LOG
end

if [ -d $OUTPUT_DIR ] 
rm -r $OUTPUT_DIR
end

echo "Warming up..."

segul summary -d $INPUT_DIR -f nexus -o $OUTPUT_DIR

echo "Benchmarking Summary Statistics"

echo "Benchmarking SEGUL" >> $OUTPUT_LOG
for i in (seq 10) do
    rm -r $OUTPUT_DIR;
    echo "Iteration $i"
    # We append the STDERR to the log file because gnu time output to STDERR
    env time -f "%E %M %P" segul summary -d $INPUT_DIR -f nexus -o $OUTPUT_DIR 2>> $OUTPUT_LOG;
end

conda activate phyluce

if [ -d $OUTPUT_DIR ] 
rm -r $OUTPUT_DIR
end

echo "Warming up..."

phyluce_align_get_align_summary_data --alignments $INPUT_DIR --core $CORES

echo "Benchmarking Phyluce" >> $OUTPUT_LOG

for i in (seq 10) do
    echo "Iteration $i"
    env time -f "%E %M %P" phyluce_align_get_align_summary_data --alignments $INPUT_DIR --core $CORES 2>> $OUTPUT_LOG;
end

### Push results to github

set Date (date +%F)

set fname "summary_bench_raw_$Date.txt"

mv OUTPUT_LOG data/$fname

git add -A && git commit -m "Add summary benchmark $Date" && git push