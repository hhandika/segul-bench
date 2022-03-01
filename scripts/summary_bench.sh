#!/usr/bin/env fish

set INPUT_DIR "shrew-nexus-clean-trimmed/"
set OUTPUT_DIR "Summary_results"
set OUTPUT_LOG "summary_bench.log"

if test -f $OUTPUT_LOG
    rm $OUTPUT_LOG
end

echo "Benchmarking Summary Statistics"

echo "Benchmarking SEGUL" >> $OUTPUT_LOG
for i in (seq 10) do
    echo "Iteration $i"
    env time -f "%E %M %P" segul summary -d $INPUT_DIR -f nexus -o $OUTPUT_DIR 2>> $OUTPUT_LOG;
    rm -r $OUTPUT_DIR;
end

echo "Benchmarking Phyluce" >> $OUTPUT_LOG
conda activate phyluce

for i in (seq 10) do
    echo "Iteration $i"
    env time -f "%E %M %P" phyluce_align_get_align_summary_data --alignments $INPUT_DIR --core 8 2>> $OUTPUT_LOG;
end