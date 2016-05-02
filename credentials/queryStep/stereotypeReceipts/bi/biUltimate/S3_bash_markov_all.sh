#!/bin/bash

# Description:
# generate markov stats
# op1: operation at step X
# op2: operation at step X+1
# elapsed: avg elapsed time in Miliseconds
# hit: frequency of the bijection op1-->op2

# declare -a profile=("sync" "cdn" "regular" "idle" "backup")
declare -a profile=("sync" "cdn" "regular" "idle" "backup")


for p in "${profile[@]}"
do
	echo $p
	#query="select op1, op2, count(*) hit, avg((EXTRACT(EPOCH FROM op2time) * 1000 + extract(millisecond from op2time)) - (EXTRACT(EPOCH FROM op1time) * 1000 + extract(millisecond from op1time))) elapsed from xl_traces_$p_min_duo group by op1, op2"
	# impala-shell -B -o "/home/lab144/chenglong/xl_markov_$p_all_ms.csv" --output_delimiter=',' -q "$query"
	#impala-shell -B -o "xl_markov_$p_all_ms.csv" --output_delimiter=',' -q "$query"
done


 


query="select op1, op2, count(*) hit, avg(elapsed) elapsed from chenglong.xl_traces_sync_min_raw group by op1, op2"
impala-shell -B -o "xl_markov_sync_all_ms.csv" --output_delimiter=',' -q "$query"

query="select op1, op2, count(*) hit, avg(elapsed) elapsed from chenglong.xl_traces_cdn_min_raw group by op1, op2"
impala-shell -B -o "xl_markov_cdn_all_ms.csv" --output_delimiter=',' -q "$query"

query="select op1, op2, count(*) hit, avg(elapsed) elapsed from chenglong.xl_traces_regular_min_raw group by op1, op2"
impala-shell -B -o "xl_markov_regular_all_ms.csv" --output_delimiter=',' -q "$query"

query="select op1, op2, count(*) hit, avg(elapsed) elapsed from chenglong.xl_traces_idle_min_raw group by op1, op2"
impala-shell -B -o "xl_markov_idle_all_ms.csv" --output_delimiter=',' -q "$query"

query="select op1, op2, count(*) hit, avg(elapsed) elapsed from chenglong.xl_traces_backup_min_raw group by op1, op2"
impala-shell -B -o "xl_markov_backup_all_ms.csv" --output_delimiter=',' -q "$query"