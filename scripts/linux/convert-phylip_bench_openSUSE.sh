#!/usr/bin/env fish

set INPUT_DIRS "alignments/esselstyn_2021_phylip" "alignments/oliveros_2019_phylip" "alignments/jarvis_2014_phylip" "alignments/chan_2020_phylip/"
set OUTPUT_DIR "other_results"
set OUTPUT_LOG "data/convert_bench.txt"
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

if [ -d $OUTPUT_DIR ]
rm -r $OUTPUT_DIR
end


echo -e "Warming up..."

segul align convert -i alignments/esselstyn_2021_phylip/*.phy -f phylip -o $OUTPUT_DIR -F fasta

echo -e "\nBenchmarking Alignment Conversion..."

echo "Benchmarking SEGUL Convert phylip to fasta" | tee -a $OUTPUT_LOG
for dir in $INPUT_DIRS
echo ""
echo -e "\nDataset path: $dir" | tee -a $OUTPUT_LOG
for i in (seq $NUM_ITERATIONS)
rm -r $OUTPUT_DIR;
echo ""
echo "Iteration $i"
# We append the STDERR to the log file because gnu time output to STDERR
env time -f "%E %M %P" segul align convert -i $dir/*.phy -f phylip -o $OUTPUT_DIR -F fasta 2>> $OUTPUT_LOG;
end
end

### SEGUL ignore datatype ###

echo -e "Benchmarking SEGUL ignore datatype" | tee -a $OUTPUT_LOG
for dir in $INPUT_DIRS
echo ""
echo -e "\nDataset path: $dir" | tee -a $OUTPUT_LOG
for i in (seq $NUM_ITERATIONS)
rm -r $OUTPUT_DIR;
echo ""
echo "Iteration $i"
# We append the STDERR to the log file because gnu time output to STDERR
env time -f "%E %M %P" segul align convert -i $dir/*.phy -f phylip -o $OUTPUT_DIR -F fasta --datatype ignore 2>> $OUTPUT_LOG;
end
end

#### AMAS ####
if [ -d $OUTPUT_DIR ]
rm -r $OUTPUT_DIR
end

echo -e "\nWarming up..."

AMAS.py convert -i alignments/esselstyn_2021_phylip/*.phy -f phylip -d dna -u fasta -c $CORES

echo -e "\nBenchmarking AMAS convert phylip to fasta" | tee -a $OUTPUT_LOG

for dir in $INPUT_DIRS
echo ""
echo -e "\nDataset path: $dir" | tee -a $OUTPUT_LOG
for i in (seq $NUM_ITERATIONS)
rm *out.phy
echo ""
echo "Iteration $i"
env time -f "%E %M %P" AMAS.py convert -i $dir/*.phy -f phylip -d dna -c $CORES -u fasta 2>> $OUTPUT_LOG;
end
end

### AMAS Check Align ####

echo -e "\nBenchmarking AMAS (check-align) convert phylip to fasta" | tee -a $OUTPUT_LOG

for dir in $INPUT_DIRS
echo ""
echo -e "\nDataset path: $dir" | tee -a $OUTPUT_LOG
for i in (seq $NUM_ITERATIONS)
rm *out.phy
echo ""
echo "Iteration $i"
env time -f "%E %M %P" AMAS.py convert -i $dir/*.phy -f phylip -d dna -c $CORES -u fasta --check-align 2>> $OUTPUT_LOG;
end
end

### Final touches ###

set Date (date +%F)

set fname "convert-phylip_bench_raw_OpenSUSE_$Date.txt"

mv $OUTPUT_LOG data/$fname

### Cleaning up ###

rm -r $OUTPUT_DIR
rm *.log
rm *out.phy
