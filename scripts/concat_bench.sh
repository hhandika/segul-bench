#!/usr/bin/env fish

set INPUT_DIRS "esselstyn_2021_nexus_trimmed" "oliveros_2019_80p_trimmed" "jarvis_2014_uce_filtered_w_gator"
set OUTPUT_DIR "concat_results"
set OUTPUT_LOG "concat_bench.log"
set CORES "24"


if test -f $OUTPUT_LOG
    rm $OUTPUT_LOG
end

if [ -d $OUTPUT_DIR ] 
rm -r $OUTPUT_DIR
end

echo -e "\nWarming up..."

segul concat -d "esselstyn_2021_nexus_trimmed" -f nexus -o $OUTPUT_DIR -F phylip

echo -e "\nBenchmarking Alignment Concatenation"

echo -e "\nBenchmarking SEGUL\n" | tee -a $OUTPUT_LOG
for dir in $INPUT_DIRS
    echo ""
    echo "Dataset path: $dir" | tee -a $OUTPUT_LOG
    for i in (seq 10)
        rm -r $OUTPUT_DIR;
        echo "Iteration $i"
        # We append the STDERR to the log file because gnu time output to STDERR
        env time -f "%E %M %P" segul concat -d $dir -f nexus -o $OUTPUT_DIR -F phylip 2>> $OUTPUT_LOG;
    end
end

#### AMAS ####

conda activate pytools

if [ -d $OUTPUT_DIR ] 
rm -r $OUTPUT_DIR
end


echo -e "\nWarming up..."

AMAS.py concat -i esselstyn_2021_nexus_trimmed/*.nex -f nexus -d dna -c $CORES

echo -e "\nBenchmarking AMAS\n" | tee -a $OUTPUT_LOG

for dir in $INPUT_DIRS
    echo ""
    echo "Dataset path: $dir" | tee -a $OUTPUT_LOG
    for i in (seq 10)
        rm concatenated.out && rm partitions.txt
        echo "Iteration $i"
        env time -f "%E %M %P" AMAS.py concat -i $dir/*.nex -f nexus -d dna -c $CORES 2>> $OUTPUT_LOG;
    end 
end


#### Phyluce ####

conda activate phyluce

if [ -d $OUTPUT_DIR ] 
rm -r $OUTPUT_DIR
end

echo -e "\nWarming up..."

phyluce_align_concatenate_alignments --alignments "esselstyn_2021_nexus_trimmed" --output $OUTPUT_DIR --phylip

echo -e "\nBenchmarking Phyluce\n" | tee -a $OUTPUT_LOG

for dir in $INPUT_DIRS
    echo ""
    echo "Dataset path: $dir" | tee -a $OUTPUT_LOG
    for i in (seq 10)
        echo "Iteration $i"
        env time -f "%E %M %P" phyluce_align_concatenate_alignments --alignments $dir --output $OUTPUT_DIR --phylip 2>> $OUTPUT_LOG;
    end 
end

