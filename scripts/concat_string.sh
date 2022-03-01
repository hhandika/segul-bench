#!/usr/bin/env fish

set INPUT_DIRS "shrew-nexus-clean-trimmed" "oliveros_2019_trimmed_80p" "jarvis_2014_uce_filtered_w_gator"

for dir in $INPUT_DIRS
    set var "$dir/*.nex";
    echo $var;
end