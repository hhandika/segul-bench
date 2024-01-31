#!/usr/bin/env fish

set INPUT_DIR "genomes"
set OUTPUT_DIR "genome_result"
set OUTPUT_LOG "data/genome_bench.txt"
set CORES 24
set NUM_ITERATIONS 5

# Remove existing log file
if test -f $OUTPUT_LOG
rm $OUTPUT_LOG
end

# Get system information
lscpu | egrep 'Model name|Thread|CPU\(s\)|Core\(s\) per socket' | tee -a $OUTPUT_LOG
uname -r  | tee -a $OUTPUT_LOG

# Get segul version
segul -V | tee -a $OUTPUT_LOG

if test -f $OUTPUT_LOG
rm $OUTPUT_LOG
end

if [ -d $OUTPUT_DIR ]
rm -r $OUTPUT_DIR
end


### SEGUL CLI
## Skip warming app to make it equivalent to SEGUL GUI
echo "Benchmarking SEGUL" | tee -a $OUTPUT_LOG

for i in (seq $NUM_ITERATIONS)
rm -r $OUTPUT_DIR;
echo ""
echo "Iteration $i"
# We append the STDERR to the log file because gnu time output to STDERR
env time -f "%E %M %P" segul read summary -d $INPUT_DIR -o $OUTPUT_DIR 2>> $OUTPUT_LOG;
end

echo "Benchmarking SEGUL GUI (LINUX)" | tee -a $OUTPUT_LOG

### Final touches ###

set Date (date +%F)

set fname "split_bench_raw_OpenSUSE_$Date.txt"

mv $OUTPUT_LOG data/$fname

### Cleaning up ###
if [ -d $OUTPUT_DIR ]
rm -r $OUTPUT_DIR
end

rm *.log
