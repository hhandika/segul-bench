#!/usr/bin/env fish

set INPUT_DIRS "alignments/esselstyn_2021_fasta" "alignments/oliveros_2019_fasta" "alignments/jarvis_2014_fasta" "alignments/chan_2020_fasta/"
set OUTPUT_DIR "concat_results"
set OUTPUT_FILE "concat"
set OUTPUT_LOG "data/concat_bench.txt"
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
goalign version | tee -a $OUTPUT_LOG

if [ -d $OUTPUT_DIR ]
rm -r $OUTPUT_DIR
end

echo -e "Warming up..."

segul align concat -i alignments/esselstyn_2021_fasta/*.fas -f fasta -o $OUTPUT_DIR -F phylip

echo -e "\nBenchmarking Alignment Concatenation"

echo "Benchmarking SEGUL" | tee -a $OUTPUT_LOG
for dir in $INPUT_DIRS
echo ""
echo "Dataset path: $dir" | tee -a $OUTPUT_LOG
for i in (seq $NUM_ITERATIONS)
rm -r $OUTPUT_DIR;
echo ""
echo "Iteration $i"
# We append the STDERR to the log file because gnu time output to STDERR
env time -f "%E %M %P" segul align concat -i $dir/*.fas -f fasta -o $OUTPUT_DIR -F phylip 2>> $OUTPUT_LOG;
end
end

### SEGUL ignore datatype ###

echo -e "Benchmarking SEGUL ignore datatype" | tee -a $OUTPUT_LOG
for dir in $INPUT_DIRS
echo ""
echo "Dataset path: $dir" | tee -a $OUTPUT_LOG
for i in (seq $NUM_ITERATIONS)
rm -r $OUTPUT_DIR;
echo ""
echo "Iteration $i"
# We append the STDERR to the log file because gnu time output to STDERR
env time -f "%E %M %P" segul align concat -i $dir/*.fas -f fasta -o $OUTPUT_DIR -F phylip --datatype ignore 2>> $OUTPUT_LOG;
end
end

#### AMAS ####
if [ -d $OUTPUT_DIR ]
rm -r $OUTPUT_DIR
end

echo -e "\nWarming up..."

AMAS.py concat -i alignments/esselstyn_2021_fasta/*.fas -f fasta -d dna -u phylip -c $CORES

echo -e "\nBenchmarking AMAS" | tee -a $OUTPUT_LOG

for dir in $INPUT_DIRS
echo ""
echo "Dataset path: $dir" | tee -a $OUTPUT_LOG
for i in (seq 10)
rm concatenated.out && rm partitions.txt
echo ""
echo "Iteration $i"
env time -f "%E %M %P" AMAS.py concat -i $dir/*.fas -f fasta -d dna -c $CORES -u phylip 2>> $OUTPUT_LOG;
end
end

### AMAS Check Align ####

echo -e "\nBenchmarking AMAS check align" | tee -a $OUTPUT_LOG

for dir in $INPUT_DIRS
echo ""
echo "Dataset path: $dir" | tee -a $OUTPUT_LOG
for i in (seq $NUM_ITERATIONS)
rm concatenated.out && rm partitions.txt
echo ""
echo "Iteration $i"
env time -f "%E %M %P" AMAS.py concat -i $dir/*.fas -f fasta -d dna -c $CORES -u phylip --check-align 2>> $OUTPUT_LOG;
end
end


#### goalign nt ####
if [ -d $OUTPUT_DIR ]
rm -r $OUTPUT_DIR
end

echo -e "\nWarming up..."

goalign concat -i alignments/esselstyn_2021_nexus_trimmed/*.fas --fasta -o $OUTPUT_FILE

echo -e "\nBenchmarking goalign (multi-core)" | tee -a $OUTPUT_LOG

for dir in $INPUT_DIRS
echo ""
echo -e "\nDataset path: $dir" | tee -a $OUTPUT_LOG
for i in (seq $NUM_ITERATIONS)
rm $OUTPUT_FILE
echo ""
echo "Iteration $i"
env time -f "%E %M %P" goalign concat -i $dir/*.fas --fasta -o $OUTPUT_FILE -t $CORES 2>> $OUTPUT_LOG;
end
end


#### goalign st ####
if [ -d $OUTPUT_DIR ]
rm -r $OUTPUT_DIR
end

echo -e "\nWarming up..."

goalign concat -i alignments/esselstyn_2021_fasta/*.fas --fasta -o $OUTPUT_FILE

echo -e "\nBenchmarking goalign (single-core)" | tee -a $OUTPUT_LOG

for dir in $INPUT_DIRS
echo ""
echo -e "\nDataset path: $dir" | tee -a $OUTPUT_LOG
for i in (seq $NUM_ITERATIONS)
rm $OUTPUT_FILE
echo ""
echo "Iteration $i"
env time -f "%E %M %P" goalign concat -i $dir/*.fas --fasta -o $OUTPUT_FILE 2>> $OUTPUT_LOG;
end
end


### Final touches ###

set Date (date +%F)

set fname "concat-fasta_bench_raw_OpenSUSE_$Date.txt"

mv $OUTPUT_LOG data/$fname

### Cleaning up ###

rm -r $OUTPUT_DIR
rm *.log
rm concatenated.out && rm partitions.txt

