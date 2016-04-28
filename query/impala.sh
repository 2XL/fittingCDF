#!/bin/bash

#S1_bash_parse_all_sid.sh

#Profile_OP1_OP2.csv
#user_id,diff_time

#declare -a profile=("sync" "cdn" "regular" "idle" "backup")
declare -a profile=("sync")
#declare -a profile=("idle" "cdn" "regular" "backup")
# parse
# xl_traces_sync_min_raw

# ssh lab144@ast12.recerca.intranet.urv.es

# -- 1r carregar un array amb els possibles variables

declare -a op1=("MakeResponse" "Unlink" "MoveResponse" "GetContentResponse" "PutContentResponse")
declare -a op2=("MakeResponse" "Unlink" "MoveResponse" "GetContentResponse" "PutContentResponse")
## now loop through the above array
for p in "${profile[@]}"
do
        for i in "${op1[@]}"
        do
                for j in "${op2[@]}"
                do
                echo "$p", "$j","$i"

                query="select user_id, elapsed from chenglong.u1_tiny_"$p"_raw where op1 = '$j' and op2 = '$i'"
                echo $query

                output="/home/lab144/chenglong/allMiliSid/"$p"_"$j"_"$i".csv"
                echo $output
                impala-shell -B -o $output --output_delimiter=',' -q "$query"

                # or do whatever with individual element of the array
                done
           # or do whatever with individual element of the array
        done
done
