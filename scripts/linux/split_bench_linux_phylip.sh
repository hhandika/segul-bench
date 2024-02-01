#!/usr/bin/env fish

set INPUT_DIR "alignments/split_alignments_phylip"
set INPUT_FILES "chan2020.phy" "esselstyn2021.phy" "jarvis2014.phy" "oliveros2019.phy" 
set PARTITION "chan2020_partition.txt" "esselstyn2021_partition.txt" "jarvis2014_partition.txt" "oliveros2019_partition.txt" 
set OUTPUT_DIR "split_results"
set OUTPUT_LOG "data/split_bench.txt"
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

segul align split -i $INPUT_DIR/chan2020.phy -f phylip -I $INPUT_DIR/chan2020_partition.txt -o $OUTPUT_DIR --output-format phylip

echo -e "\nBenchmarking Alignment Splitting PHYLIP"

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
env time -f "%E %M %P" segul align split -i $INPUT_DIR/$file -f phylip -I $INPUT_DIR/$PARTITION[$index] -p raxml -o $OUTPUT_DIR --output-format phylip 2>> $OUTPUT_LOG;

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
env time -f "%E %M %P" segul align split -i $INPUT_DIR/$file -f phylip -I $INPUT_DIR/$PARTITION[$index] -p raxml -o $OUTPUT_DIR --output-format phylip --datatype ignore 2>> $OUTPUT_LOG;
end
end

#### AMAS ####
if [ -d $OUTPUT_DIR ]
rm -r $OUTPUT_DIR
end


echo -e "\nWarming up..."
AMAS.py split -i $INPUT_DIR/chan2020.phy -f phylip -d dna -l $INPUT_DIR/chan2020_partition.txt -d dna -u phylip -c $CORES

echo -e "\nBenchmarking AMAS (--remove-empty)" | tee -a $OUTPUT_LOG
for file in $INPUT_FILES
echo ""
echo "Dataset path: $file" | tee -a $OUTPUT_LOG
set index (contains -i -- $file $INPUT_FILES)
for i in (seq $NUM_ITERATIONS)
echo ""
echo "Iteration $i"
env time -f "%E %M %P" AMAS.py split -i $INPUT_DIR/$file -f phylip -d dna -l $INPUT_DIR/$PARTITION[$index] -u phylip --remove-empty -c $CORES 2>> $OUTPUT_LOG;
end
end

### AMAS with empty sequences ###

echo -e "\nBenchmarking AMAS KEEP EMPTY" | tee -a $OUTPUT_LOG
for file in $INPUT_FILES
echo ""
echo "Dataset path: $file" | tee -a $OUTPUT_LOG
set index (contains -i -- $file $INPUT_FILES)
for i in (seq $NUM_ITERATIONS)
echo ""
echo "Iteration $i"
env time -f "%E %M %P" AMAS.py split -i $INPUT_DIR/$file -f phylip -d dna -l $INPUT_DIR/$PARTITION[$index] -u phylip -c $CORES 2>> $OUTPUT_LOG;
end
end

### Final touches ###

set Date (date +%F)

set fname "split-phylip_bench_raw_OpenSUSE_$Date.txt"

mv $OUTPUT_LOG data/$fname

### Cleaning up ###
if [ -d $OUTPUT_DIR ]
rm -r $OUTPUT_DIR
end

rm *.log
