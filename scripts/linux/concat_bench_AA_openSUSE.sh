#!/usr/bin/env fish

set INPUT_DIRS "alignments/wu_2018_aa_loci/" "alignments/shen_2018_loci_aa/"
set OUTPUT_DIR "concat_results_aa"
set OUTPUT_FILE "concat"
set OUTPUT_LOG "data/concat_bench_aa.txt"
set CORES 24

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

segul align concat -i alignments/wu_2018_aa_loci/*.nex -f nexus -o $OUTPUT_DIR -F phylip --datatype aa

echo -e "\nBenchmarking Alignment Concatenation AA"

echo "Benchmarking SEGUL" | tee -a $OUTPUT_LOG
for dir in $INPUT_DIRS
echo ""
echo "Dataset path: $dir" | tee -a $OUTPUT_LOG
for i in (seq 10)
rm -r $OUTPUT_DIR;
echo ""
echo "Iteration $i"
# We append the STDERR to the log file because gnu time output to STDERR
env time -f "%E %M %P" segul align concat -i $dir/*.nex -f nexus -o $OUTPUT_DIR -F phylip --datatype aa 2>> $OUTPUT_LOG;
end
end

### SEGUL ignore datatype ###

echo -e "Benchmarking SEGUL ignore datatype" | tee -a $OUTPUT_LOG
for dir in $INPUT_DIRS
echo ""
echo "Dataset path: $dir" | tee -a $OUTPUT_LOG
for i in (seq 10)
rm -r $OUTPUT_DIR;
echo ""
echo "Iteration $i"
# We append the STDERR to the log file because gnu time output to STDERR
env time -f "%E %M %P" segul align concat -i $dir/*.nex -f nexus -o $OUTPUT_DIR -F phylip --datatype ignore 2>> $OUTPUT_LOG;
end
end

#### AMAS ####
if [ -d $OUTPUT_DIR ]
rm -r $OUTPUT_DIR
end


echo -e "\nWarming up..."

AMAS.py concat -i -i alignments/wu_2018_aa_loci/*.nex -f nexus -d aa -u phylip -c $CORES

echo -e "\nBenchmarking AMAS" | tee -a $OUTPUT_LOG

for dir in $INPUT_DIRS
echo ""
echo "Dataset path: $dir" | tee -a $OUTPUT_LOG
for i in (seq 10)
rm concatenated.out && rm partitions.txt
echo ""
echo "Iteration $i"
env time -f "%E %M %P" AMAS.py concat -i $dir/*.nex -f nexus -d aa -u phylip -c $CORES 2>> $OUTPUT_LOG;
end
end

### AMAS Check Align ####

echo -e "\nBenchmarking AMAS" | tee -a $OUTPUT_LOG

for dir in $INPUT_DIRS
echo ""
echo "Dataset path: $dir" | tee -a $OUTPUT_LOG
for i in (seq 10)
rm concatenated.out && rm partitions.txt
echo ""
echo "Iteration $i"
env time -f "%E %M %P" AMAS.py concat -i $dir/*.nex -f nexus -d aa -u phylip -c $CORES --check-align 2>> $OUTPUT_LOG;
end
end


#### goalign nt ####
if [ -d $OUTPUT_DIR ]
rm -r $OUTPUT_DIR
end

echo -e "\nWarming up..."

goalign concat -i alignments/wu_2018_aa_loci/*.nex --nexus -o $OUTPUT_FILE

echo -e "\nBenchmarking goalign nt" | tee -a $OUTPUT_LOG

for dir in $INPUT_DIRS
echo ""
echo -e "\nDataset path: $dir" | tee -a $OUTPUT_LOG
for i in (seq 10)
rm $OUTPUT_FILE
echo ""
echo "Iteration $i"
env time -f "%E %M %P" goalign concat -i $dir/*.nex --nexus -o $OUTPUT_FILE -t $CORES 2>> $OUTPUT_LOG;
end
end

#### goalign st ####
if [ -d $OUTPUT_DIR ]
rm -r $OUTPUT_DIR
end

echo -e "\nWarming up..."

goalign concat -i alignments/wu_2018_aa_loci/*.nex --nexus -o $OUTPUT_FILE

echo -e "\nBenchmarking goalign st" | tee -a $OUTPUT_LOG

for dir in $INPUT_DIRS
echo ""
echo -e "\nDataset path: $dir" | tee -a $OUTPUT_LOG
for i in (seq 10)
rm $OUTPUT_FILE
echo ""
echo "Iteration $i"
env time -f "%E %M %P" goalign concat -i $dir/*.nex --nexus -o $OUTPUT_FILE 2>> $OUTPUT_LOG;
end
end


### Final touches ###

set Date (date +%F)

set fname "concat_bench_raw_aa_OpenSUSE_$Date.txt"

mv $OUTPUT_LOG data/$fname

### Cleaning up ###

rm -r $OUTPUT_DIR
rm *.log
rm concatenated.out && rm partitions.txt

### Push to Github ###

#git add -A && git commit -m "Add concatenation benchmark" && git push

