#!/usr/bin/env fish

set INPUT_DIRS "shrew-nexus-clean-trimmed" "oliveros_2019_trimmed_80p" "jarvis_2014_uce_filtered_w_gator"
set OUTPUT_DIR "Summary_results"
set OUTPUT_LOG "summary_bench.log"
set CORES "24"

if test -f $OUTPUT_LOG
    rm $OUTPUT_LOG
end

if [ -d $OUTPUT_DIR ] 
rm -r $OUTPUT_DIR
end

echo "Warming up..."

segul concat -d "shrew-nexus-clean-trimmed" -f nexus -o $OUTPUT_DIR -F phylip

echo "Benchmarking Alignment Concatenation"

echo "Benchmarking SEGUL" | tee $OUTPUT_LOG
for dir in $INPUT_DIRS
    echo "Dataset path: $dir" | tee $OUTPUT_LOG
    for i in (seq 10)
        rm -r $OUTPUT_DIR;
        echo "Iteration $i"
        # We append the STDERR to the log file because gnu time output to STDERR
        env time -f "%E %M %P" segul concat -d $dir -f nexus -o $OUTPUT_DIR -F phylip 2>> $OUTPUT_LOG;
    end
end

conda activate phyluce

if [ -d $OUTPUT_DIR ] 
rm -r $OUTPUT_DIR
end

echo "Warming up..."

phyluce_align_concatenate_alignments --alignments "shrew-nexus-clean-trimmed" --output $OUTPUT_DIR --phylip

echo "Benchmarking Phyluce" | tee $OUTPUT_LOG

for dir in $INPUT_DIRS
    echo "Dataset path: $dir" | tee $OUTPUT_LOG
    for i in (seq 10)
        echo "Iteration $i"
        env time -f "%E %M %P" phyluce_align_concatenate_alignments --alignments $dir --output $OUTPUT_DIR --phylip 2>> $OUTPUT_LOG;
    end 
end