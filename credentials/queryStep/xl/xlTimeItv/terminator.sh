#!/bin/bash




# parse
# xl_traces_sync_min_raw

# ssh lab144@ast12.recerca.intranet.urv.es

# -- 1r carregar un array amb els possibles variables


declare -a profile=("cdn" "regular" "idle" "backup" "sync")
declare -a stereotype=("active" "noop" "offline")

## now loop through the above array
for pp in "${profile[@]}"
do
 for s in "${stereotype[@]}"
 do
  qq="select ini_timeslot, session_length from chenglong.xls_sessions_$pp where type = '$s' order by ini_timeslot asc"
  out="/home/lab144/chenglong/xls_sessions_$pp_$s.csv"
  echo $qq
  echo $pp
  echo $out
  impala-shell -B -o "$out" --output_delimiter=',' -q "$qq"
  # or do whatever with individual element of the array
  done
done







select t, 
active/total*100 a_rate, noop/total*100 n_rate, offline/total*100 o_rate, active, noop, offline, t_active, t_noop, t_offline, total from
(

select 
floor(ini_timeslot) t, 
sum(case when type='active' then 1 else 0 end) active,
sum(case when type='noop' then 1 else 0 end) noop,
sum(case when type='offline' then 1 else 0 end) offline,
sum(case when type='active' then session_length else 0 end) t_active,
sum(case when type='noop' then session_length else 0 end) t_noop,
sum(case when type='offline' then session_length else 0 end) t_offline,
count(*) total 
from xls_sessions_cdn
group by floor(ini_timeslot)

) temp
order by t asc;





select t, 
active/total*100 a_rate, noop/total*100 n_rate, offline/total*100 o_rate, active, noop, offline, t_active, t_noop, t_offline, total from
(

select 
floor(ini_timeslot) t, 
sum(case when type='active' then 1 else 0 end) active,
sum(case when type='noop' then 1 else 0 end) noop,
sum(case when type='offline' then 1 else 0 end) offline,
sum(case when type='active' then session_length else 0 end) t_active,
sum(case when type='noop' then session_length else 0 end) t_noop,
sum(case when type='offline' then session_length else 0 end) t_offline,
count(*) total 
from xls_sessions_idle
group by floor(ini_timeslot)

) temp
order by t asc;



select t, 
active/total*100 a_rate, noop/total*100 n_rate, offline/total*100 o_rate, active, noop, offline, t_active, t_noop, t_offline, total from
(

select 
floor(ini_timeslot) t, 
sum(case when type='active' then 1 else 0 end) active,
sum(case when type='noop' then 1 else 0 end) noop,
sum(case when type='offline' then 1 else 0 end) offline,
sum(case when type='active' then session_length else 0 end) t_active,
sum(case when type='noop' then session_length else 0 end) t_noop,
sum(case when type='offline' then session_length else 0 end) t_offline,
count(*) total 
from xls_sessions_backup
group by floor(ini_timeslot)

) temp
order by t asc;



select t, 
active/total*100 a_rate, noop/total*100 n_rate, offline/total*100 o_rate, active, noop, offline, t_active, t_noop, t_offline, total from
(

select 
floor(ini_timeslot) t, 
sum(case when type='active' then 1 else 0 end) active,
sum(case when type='noop' then 1 else 0 end) noop,
sum(case when type='offline' then 1 else 0 end) offline,
sum(case when type='active' then session_length else 0 end) t_active,
sum(case when type='noop' then session_length else 0 end) t_noop,
sum(case when type='offline' then session_length else 0 end) t_offline,
count(*) total 
from xls_sessions_sync
group by floor(ini_timeslot)

) temp
order by t asc;



 

select t, 
active/total*100 a_rate, noop/total*100 n_rate, offline/total*100 o_rate, active, noop, offline, t_active, t_noop, t_offline, total from
(

select 
floor(ini_timeslot) t, 
sum(case when type='active' then 1 else 0 end) active,
sum(case when type='noop' then 1 else 0 end) noop,
sum(case when type='offline' then 1 else 0 end) offline,
sum(case when type='active' then session_length else 0 end) t_active,
sum(case when type='noop' then session_length else 0 end) t_noop,
sum(case when type='offline' then session_length else 0 end) t_offline,
count(*) total 
from xls_sessions_regular
group by floor(ini_timeslot)

) temp
order by t asc;