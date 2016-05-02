#!/bin/bash






# u1stereo_sync
# u1stereo_backup
# u1stereo_download


declare -a profile=("download" "sync" "backup")
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

                query="select user_id, elapsed from u1stereo.operation_chain_"$p" where op1 = '$j' and op2 = '$i'"
                echo $query

                output="/home/lab144/chenglong/stereo/"$p"_"$j"_"$i".csv"
                echo $output
                impala-shell -B -o $output --output_delimiter=',' -q "$query"

                # or do whatever with individual element of the array
                done
           # or do whatever with individual element of the array
        done
done
 
