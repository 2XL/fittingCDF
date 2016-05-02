#!/bin/bash

 export LC_CTYPE=${LC_CTYPE:-en_US.UTF-8}

# declare -a profile=("sync" "cdn" "regular" "idle" "backup")
declare -a profile=("sync" "cdn" "regular" "idle" "backup")

for p in "${profile[@]}"
do
	echo $p
 
	query="select op1, op2, count(*) hit, avg(elapsed) elapsed from chenglong.u1_tiny_"$p"_raw group by op1, op2"
	impala-shell -B -o "xl_markov_"$p"_all_sid_ms.csv" --output_delimiter=',' -q "$query"
done


 
 

 