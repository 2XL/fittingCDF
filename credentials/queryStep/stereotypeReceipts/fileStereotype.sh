#!/usr/bin/env bash


# per e

declare -a profile=("download" "backup" "sync") #
declare -a operator=("PutContentResponse" "GetContentResponse" "MoveResponse" "Unlink" "MakeResponse") # operation
# # req_t in ('PutContentResponse', 'GetContentResponse', 'MoveResponse', 'Unlink', 'MakeResponse');

## now loop through the above array
for pp in "${profile[@]}"
do
 for op in "${operator[@]}"
 do
  qq="select ini_timeslot, session_length from chenglong.xls_sessions_$pp where type = '$op' order by ini_timeslot asc"
  out="/home/lab144/chenglong/profiling/files/u1_file_$pp_$op.csv"
  echo $qq
  echo $pp
  echo $out
  impala-shell -B -o "$out" --output_delimiter=',' -q "$qq"
  # or do whatever with individual element of the array
  done
done

