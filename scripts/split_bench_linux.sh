#!/usr/bin/env fish

set INPUT_FILE "alignments/Onn_2020_all_combined/alignment_all-combined.phy"
set PARTITION "alignments/Onn_2020_all_combined/partitions_all-combined.txt"
set OUTPUT_DIR "split_results"
set OUTPUT_LOG "data/split_bench.txt"
set CORES 24


# Get system information
uname -r | tee $OUTPUT_LOG

if test -f $OUTPUT_LOG
rm $OUTPUT_LOG
end

if [ -d $OUTPUT_DIR ]
rm -r $OUTPUT_DIR
end

echo -e "Warming up..."

segul split -i $INPUT_FILE -f phylip -o $OUTPUT_DIR -F phylip

echo -e "\nBenchmarking Alignment Splitting"

echo "Benchmarking SEGUL" | tee -a $OUTPUT_LOG

for i in (seq 10)
rm -r $OUTPUT_DIR;
echo ""
echo "Iteration $i"
# We append the STDERR to the log file because gnu time output to STDERR
env time -f "%E %M %P" segul split -i $INPUT_FILE -f phylip -I PARTITION -p raxml -o $OUTPUT_DIR -F phylip 2>> $OUTPUT_LOG;
end

### SEGUL ignore datatype ###

echo -e "Benchmarking SEGUL ignore datatype" | tee -a $OUTPUT_LOG
for i in (seq 10)
rm -r $OUTPUT_DIR;
echo ""
echo "Iteration $i"
# We append the STDERR to the log file because gnu time output to STDERR
env time -f "%E %M %P" segul split -i $INPUT_FILE -f phylip -I PARTITION -p raxml -o $OUTPUT_DIR -F phylip --datatype ignore 2>> $OUTPUT_LOG;
end

#### AMAS ####
if [ -d $OUTPUT_DIR ]
rm -r $OUTPUT_DIR
end


echo -e "\nWarming up..."

AMAS.py split -i $INPUT_FILE -f phylip -d dna -u phylip -c $CORES

echo -e "\nBenchmarking AMAS" | tee -a $OUTPUT_LOG
rm $INPUT_FILE/alignment_all-combined_*
for i in (seq 10)
rm 
echo ""
echo "Iteration $i"
env time -f "%E %M %P" AMAS.py split -i $INPUT_FILE -f phylip -d dna -l $PARTITION -u phylip --remove-empty -c $CORES 2>> $OUTPUT_LOG;
end
end


### Final touches ###

set Date (date +%F)

set fname "split_bench_raw_OpenSUSE_$Date.txt"

mv $OUTPUT_LOG data/$fname

### Cleaning up ###

rm -r $OUTPUT_DIR
rm *.log
rm $INPUT_FILE/alignment_all-combined_*

### Push to Github ###

git add -A && git commit -m "Add concatenation benchmark" && git push

