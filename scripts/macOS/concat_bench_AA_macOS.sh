#!/opt/homebrew/bin/fish

set INPUT_DIRS "alignments/wu_2018_aa_loci/" "alignments/shen_2018_loci_aa/"
set OUTPUT_DIR "concat_results_aa"
set OUTPUT_LOG "data/concat_bench_aa.txt"
set CORES 8

# Remove existing log file
if test -f $OUTPUT_LOG
rm $OUTPUT_LOG
end

# Get system information
uname -v  | tee -a $OUTPUT_LOG

# Get segul version
segul -V | tee -a $OUTPUT_LOG

if [ -d $OUTPUT_DIR ]
rm -r $OUTPUT_DIR
end

echo -e "Warming up..."

segul concat -i alignments/wu_2018_aa_loci/*.nex -f nexus -o $OUTPUT_DIR -F phylip --datatype aa

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
gtime -f "%E %M %P" segul concat -i $dir/*.nex -f nexus -o $OUTPUT_DIR -F phylip --datatype aa 2>> $OUTPUT_LOG;
end
end

echo -e "Benchmarking SEGUL ignore datatype" | tee -a $OUTPUT_LOG
for dir in $INPUT_DIRS
echo ""
echo "Dataset path: $dir" | tee -a $OUTPUT_LOG
for i in (seq 10)
rm -r $OUTPUT_DIR;
echo ""
echo "Iteration $i"
# We append the STDERR to the log file because gnu time output to STDERR
gtime -f "%E %M %P" segul concat -i $dir/*.nex -f nexus -o $OUTPUT_DIR -F phylip --datatype ignore 2>> $OUTPUT_LOG;
end
end

#### AMAS ####

if [ -d $OUTPUT_DIR ]
rm -r $OUTPUT_DIR
end


echo -e "\nWarming up..."

AMAS.py concat -i alignments/wu_2018_aa_loci/*.nex -f nexus -d aa -u phylip -c $CORES

echo -e "\nBenchmarking AMAS" | tee -a $OUTPUT_LOG

for dir in $INPUT_DIRS
echo ""
echo "Dataset path: $dir" | tee -a $OUTPUT_LOG
for i in (seq 10)
rm concatenated.out && rm partitions.txt
echo ""
echo "Iteration $i"
gtime -f "%E %M %P" AMAS.py concat -i $dir/*.nex -f nexus -d aa -u phylip -c $CORES 2>> $OUTPUT_LOG;
end
end

echo -e "\nBenchmarking AMAS Check Aligned" | tee -a $OUTPUT_LOG

for dir in $INPUT_DIRS
echo ""
echo "Dataset path: $dir" | tee -a $OUTPUT_LOG
for i in (seq 10)
rm concatenated.out && rm partitions.txt
echo ""
echo "Iteration $i"
gtime -f "%E %M %P" AMAS.py concat -i $dir/*.nex -f nexus -d aa -u phylip -c $CORES --check-align 2>> $OUTPUT_LOG;
end
end

### Final touches ###

set Date (date +%F)

set fname "concat_bench_raw_aa_MacMini_$Date.txt"

mv $OUTPUT_LOG data/$fname

### Cleaning up ###

rm -r $OUTPUT_DIR
rm *.log
rm concatenated.out && rm partitions.txt

### Push to Github ###

git add -A && git commit -m "Add concatenation benchmark" && git push

