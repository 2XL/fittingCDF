#!/usr/bin/env bash



qq="select multipart, count(*) hit from u1stereo.u1file_with_mime where multipart in (select * from  u1stereo.u1mime_considered) group by multipart order by hit desc"
out="/home/lab144/chenglong/martes/cdf_file_type.csv"
impala-shell -B -o "$out" --output_delimiter=',' -q "$qq"




# per e
#
#declare -a profile=("download" "backup" "sync") #
#declare -a operator=("PutContentResponse" "GetContentResponse" "MoveResponse" "Unlink" "MakeResponse") # operation
## # req_t in ('PutContentResponse', 'GetContentResponse', 'MoveResponse', 'Unlink', 'MakeResponse');
#
### now loop through the above array
#for pp in "${profile[@]}"
#do
# for op in "${operator[@]}"
# do
#  qq="select ini_timeslot, session_length from chenglong.xls_sessions_$pp where type = '$op' order by ini_timeslot asc"
#  out="/home/lab144/chenglong/profiling/files/u1_file_$pp_$op.csv"
#  echo $qq
#  echo $pp
#  echo $out
#  impala-shell -B -o "$out" --output_delimiter=',' -q "$qq"
#  # or do whatever with individual element of the array
#  done
#done

