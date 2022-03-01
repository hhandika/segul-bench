#!/usr/bin/env fish

set INPUT_DIR "shrew-nexus-clean-trimmed/"
set OUTPUT_DIR "Summary_results"
set OUTPUT_LOG "summary_bench.log"

if test -f $OUTPUT_LOG
    rm $OUTPUT_LOG
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

echo "Warming up..."

phyluce_align_get_align_summary_data --alignments $INPUT_DIR --core 8

echo "Benchmarking Phyluce" >> $OUTPUT_LOG

for i in (seq 10) do
    echo "Iteration $i"
    env time -f "%E %M %P" phyluce_align_get_align_summary_data --alignments $INPUT_DIR --core 8 2>> $OUTPUT_LOG;
end