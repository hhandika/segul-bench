#!/usr/bin/env fish

set OUTPUT_LOG "data/concat_bench.log"

set Date (date +%F)

set fname "concat_bench_raw_$Date.txt"

mv $OUTPUT_LOG data/$fname