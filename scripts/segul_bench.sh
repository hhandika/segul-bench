#!/usr/bin/env fish

set OUTPUT_DIR "Summary_results"

echo "Benchmarking segul" >> segul_bench.log
for i in {1..10} do
    env time -f "%E %M %P" segul summary -d shrew-nexus-clean-trimmed/ -f nexus -o $OUTPUT_DIR >> segul_bench.log;
    rm -r $OUTPUT_DIR;
end