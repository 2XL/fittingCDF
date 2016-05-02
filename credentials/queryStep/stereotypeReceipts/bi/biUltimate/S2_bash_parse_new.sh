#!/bin/bash




#Profile_OP1_OP2.csv
#user_id,diff_time

#declare -a profile=("sync" "cdn" "regular" "idle" "backup")
#declare -a profile=("idle")
declare -a profile=("cdn" "regular" "idle" "backup")

# parse
# xl_traces_sync_min_raw

# ssh lab144@ast12.recerca.intranet.urv.es

# -- 1r carregar un array amb els possibles variables



declare -a op1=("MakeResponse")
declare -a op2=("MakeResponse")
## now loop through the above array
for p in "${profile[@]}"
do
	for i in "${op1[@]}"
	do
	        for j in "${op2[@]}"
	                do
	                # echo "$j","$i"

	                query="select user_id, elapsed from chenglong.xl_traces_$p_new_raw where op1 = '$j' and op2 = '$i'"
	                echo $query

	                impala-shell -B -o "/home/lab144/chenglong/$p_$j_$i.csv" --output_delimiter=',' -q "$query"

	                # or do whatever with individual element of the array
	                done
	   # or do whatever with individual element of the array
	done
done           