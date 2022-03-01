#!/usr/bin/env fish

set INPUT_DIR "shrew-nexus-clean-trimmed/"
set OUTPUT_DIR "concat_results"
set OUTPUT_LOG "concat_bench.log"
set MESSAGE "Iteration $i"

if test -f $OUTPUT_LOG
rm $OUTPUT_LOG
end

echo "Benchmarking Alignment Concatenation"

echo "Benchmarking SEGUL" >> $OUTPUT_LOG

for i in (seq 10) do
    echo $MESSAGE
    env time -f "%E %M %P" segul concat -d $INPUT_DIR -f nexus -o $OUTPUT_DIR -F phylip-int 2>> $OUTPUT_LOG;
    rm -r $OUTPUT_DIR;
end

echo "Benchmarking Phyluce" >> $OUTPUT_LOG
conda activate phyluce

for i in (seq 10) do
    echo $MESSAGE
    env time -f "%E %M %P" phyluce_align_concatenate_alignments --alignments $INPUT_DIR --output $OUTPUT_DIR --phylip 2>> $OUTPUT_LOG;
    rm -r $OUTPUT_DIR;
end

