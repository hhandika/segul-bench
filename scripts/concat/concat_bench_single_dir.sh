#!/usr/bin/env fish

set INPUT_DIR "shrew-nexus-clean-trimmed/"
set OUTPUT_DIR "concat_results"
set OUTPUT_LOG "concat_bench.log"

if test -f $OUTPUT_LOG
rm $OUTPUT_LOG
end

if [ -d $OUTPUT_DIR ] 
rm -r $OUTPUT_DIR
end

echo "Warming up..."

segul concat -d $INPUT_DIR -f nexus -o $OUTPUT_DIR -F phylip

echo "Benchmarking Alignment Concatenation"

echo "Benchmarking SEGUL" >> $OUTPUT_LOG

for i in (seq 10) do
    rm -r $OUTPUT_DIR;
    echo "Iteration $i"
    env time -f "%E %M %P" segul concat -d $INPUT_DIR -f nexus -o $OUTPUT_DIR -F phylip 2>> $OUTPUT_LOG;
end

conda activate phyluce

if [ -d $OUTPUT_DIR ] 
rm -r $OUTPUT_DIR
end

echo "Warming up..."

phyluce_align_concatenate_alignments --alignments $INPUT_DIR --output $OUTPUT_DIR --phylip

echo "Benchmarking Phyluce" >> $OUTPUT_LOG

for i in (seq 10) do
    rm -r $OUTPUT_DIR;
    echo "Iteration $i"
    env time -f "%E %M %P" phyluce_align_concatenate_alignments --alignments $INPUT_DIR --output $OUTPUT_DIR --phylip 2>> $OUTPUT_LOG;
end

