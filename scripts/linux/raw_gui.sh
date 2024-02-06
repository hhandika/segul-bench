#!/usr/bin/env fish

set OUTPUT_DIR "~/Downloads/tests"
set OUTPUT_LOG "~/Downloads/segui_bench.txt"

env time -f "%E %M %P" build/linux/x64/release/bundle/segui

tail -n 1 ~/Documents/segul_2024-02-06.log