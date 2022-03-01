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

segul summary -d "shrew-nexus-clean-trimmed/" -f nexus -o $OUTPUT_DIR

echo "\nBenchmarking Summary Statistics\n"

echo "Benchmarking SEGUL" | tee $OUTPUT_LOG
for dir in $INPUT_DIRS
    echo "Dataset path: $dir" | tee $OUTPUT_LOG
    for i in (seq 10)
        rm -r $OUTPUT_DIR;
        echo "Iteration $i"
        # We append the STDERR to the log file because gnu time output to STDERR
        env time -f "%E %M %P" segul summary -d $dir -f nexus -o $OUTPUT_DIR 2>> $OUTPUT_LOG;
    end
end

conda activate phyluce

if [ -d $OUTPUT_DIR ] 
rm -r $OUTPUT_DIR
end

echo "\nWarming up...\n"

phyluce_align_get_align_summary_data --alignments "shrew-nexus-clean-trimmed/" --core $CORES

echo "Benchmarking Phyluce" | tee $OUTPUT_LOG

for dir in $INPUT_DIRS
    echo "Dataset path: $dir" | tee $OUTPUT_LOG
    for i in (seq 10)
        echo "Iteration $i"
        env time -f "%E %M %P" phyluce_align_get_align_summary_data --alignments $dir --core $CORES 2>> $OUTPUT_LOG;
    end 
end