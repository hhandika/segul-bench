#!/usr/bin/env fish

set INPUT_DIR "alignments/split_alignments_fasta"
set INPUT_FILES "shen2018.fas" "wu2018.fas"
set PARTITION "shen2018_partition.txt" "wu2018_partition.txt"
set OUTPUT_DIR "split_results"
set OUTPUT_LOG "data/split_bench_AA.txt"
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

# Clean unnecessary files
if test -f $OUTPUT_LOG
rm $OUTPUT_LOG
end

if [ -d $OUTPUT_DIR ]
rm -r $OUTPUT_DIR
end

echo -e "Warming up..."

segul align split -i $INPUT_DIR/shen2018.fas -f fasta -I $INPUT_DIR/shen2018_partition.txt -o $OUTPUT_DIR --output-format fasta --datatype aa

echo -e "\nBenchmarking Alignment Splitting FASTA"

echo "Benchmarking SEGUL" | tee -a $OUTPUT_LOG
for file in $INPUT_FILES
echo ""
echo "Dataset path: $file" | tee -a $OUTPUT_LOG
set index (contains -i -- $file $INPUT_FILES)
for i in (seq $NUM_ITERATIONS)
rm -r $OUTPUT_DIR;
echo ""
echo "Iteration $i"
# We append the STDERR to the log file because gnu time output to STDERR
env time -f "%E %M %P" segul align split -i $INPUT_DIR/$file -f fasta -I $INPUT_DIR/$PARTITION[$index] -p raxml -o $OUTPUT_DIR --output-format fasta --datatype aa 2>> $OUTPUT_LOG;
end
end

### SEGUL ignore datatype ###

echo -e "\nBenchmarking SEGUL ignore datatype" | tee -a $OUTPUT_LOG
for file in $INPUT_FILES
echo ""
echo "Dataset path: $file" | tee -a $OUTPUT_LOG
set index (contains -i -- $file $INPUT_FILES)
for i in (seq $NUM_ITERATIONS)
rm -r $OUTPUT_DIR;
echo ""
echo "Iteration $i"
# We append the STDERR to the log file because gnu time output to STDERR
env time -f "%E %M %P" segul align split -i $INPUT_DIR/$file -f fasta -I $INPUT_DIR/$PARTITION[$index] -p raxml -o $OUTPUT_DIR --output-format fasta --datatype ignore 2>> $OUTPUT_LOG;
end
end

#### AMAS ####
if [ -d $OUTPUT_DIR ]
rm -r $OUTPUT_DIR
end


echo -e "\nWarming up..."
AMAS.py split -i $INPUT_DIR/shen2018.fas -f fasta -d aa -l $INPUT_DIR/shen2018_partition.txt -d aa -u fasta -c $CORES

echo -e "\nBenchmarking AMAS (--remove-empty)" | tee -a $OUTPUT_LOG
for file in $INPUT_FILES
echo ""
echo "Dataset path: $file" | tee -a $OUTPUT_LOG
set index (contains -i -- $file $INPUT_FILES)
set index (contains -i -- $file $INPUT_FILES)
for i in (seq $NUM_ITERATIONS)
rm $INPUT_DIR/$file_*
echo ""
echo "Iteration $i"
env time -f "%E %M %P" AMAS.py split -i $INPUT_DIR/$file -f fasta -d aa -l $INPUT_DIR/$PARTITION[$index] -u fasta --remove-empty -c $CORES 2>> $OUTPUT_LOG;
end
end

### AMAS with empty sequences ###

echo -e "\nBenchmarking AMAS KEEP EMPTY" | tee -a $OUTPUT_LOG
for file in $INPUT_FILES
echo ""
echo "Dataset path: $file" | tee -a $OUTPUT_LOG
set index (contains -i -- $file $INPUT_FILES)
for i in (seq $NUM_ITERATIONS)
rm $INPUT_DIR/$file_*
echo ""
echo "Iteration $i"
env time -f "%E %M %P" AMAS.py split -i $INPUT_DIR/$file -f fasta -d aa -l $INPUT_DIR/$PARTITION[$index] -u fasta -c $CORES 2>> $OUTPUT_LOG;
end
end

### Final touches ###

set Date (date +%F)

set fname "split_bench_raw_OpenSUSE_AA_$Date.txt"

mv $OUTPUT_LOG data/$fname

### Cleaning up ###
if [ -d $OUTPUT_DIR ]
rm -r $OUTPUT_DIR
end

rm *.log
