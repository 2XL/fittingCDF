 




drop table if exists xls_traces_sync;

create table xls_traces_sync (
user_id bigint,
sid string, 
tstamp timestamp,
req_t string
) stored as parquet;

insert into xls_traces_sync
select user_id, sid, tstamp, req_t from default.ubuntu_one u1
where 
sid != '' and 
t = 'storage_done' and
user_id in ( select * from xlp_profile_sync );

show table stats xls_traces_sync;






------------------------------------------------------------------------------------------------------------


-- traces -> sessions instead of traces

drop table if exists xls_traces_sync_session_count;

create table xls_traces_sync_session_count (
user_id bigint,
sid string, 
ini timestamp,
fin timestamp,
hit_make bigint,
hit_get bigint,
hit_put bigint,
hit_unlink bigint,
hit_move bigint
) stored as parquet;


insert into xls_traces_sync_session_count
select 
	user_id, 
	sid,  
	min(tstamp) ini, 
	max(tstamp) fin, 
	sum(case when req_t = 'MakeResponse' then 1 else 0 end) hitMake,
	sum(case when req_t = 'GetContentResponse' then 1 else 0 end) hitGet,
	sum(case when req_t = 'PutContentResponse' then 1 else 0 end) hitPut,
	sum(case when req_t = 'Unlink' then 1 else 0 end) hitUnlink,
	sum(case when req_t = 'MoveResponse' then 1 else 0 end) hitMove 
from xls_traces_sync
group by user_id, sid;

-- show table stats xls_traces_sync_session_count;


 

------------------------------------------------------------------------------------------------------------

  
-- primera aproximació...



 

-- all sessions
drop table if exists xls_traces_sync_session_count_rel;

create table xls_traces_sync_session_count_rel (
user_id bigint,
idx_rel bigint,
idx_next bigint, 
ini timestamp,
fin timestamp,
hit bigint
) stored as parquet;

insert into xls_traces_sync_session_count_rel
select user_id, idx_rel, idx_rel+1 idx_next, ini, fin, (hit_make+hit_get+hit_put+hit_unlink+hit_move) as hit from
(
select dense_rank() over (partition by user_id order by ini) as idx_rel, *
from xls_traces_sync_session_count 
)t;

-- show table stats xls_traces_sync_session_count_rel;






------------------------------------------------------------------------------------------------------------
--> duo

drop table if exists xls_traces_sync_session_count_XX;

create table xls_traces_sync_session_count_XX
  (
    user_id bigint,
    idx bigint,
    idx_n bigint,
    t_ini timestamp,
    t_fin timestamp,
    t_n timestamp, -- need to hardcode, if idx_n == null then tstamp_sync -> max traces
    hit bigint
    ) stored as parquet;




insert into xls_traces_sync_session_count_XX
  select 
    a.user_id,
    a.idx_rel,
    a.idx_next,
    a.ini,
    a.fin,
    b.ini, -- isnull(b.ini, 2014-02-11 06:25:31.817000000 ),
    a.hit
    from xls_traces_sync_session_count_rel a
    left join xls_traces_sync_session_count_rel b 
    on (a.user_id = b.user_id and a.idx_next = b.idx_rel)
where b.ini is not null; -- no podem saber la duració de la sessió, podem saber que dura més...


show table stats xls_traces_sync_session_count_XX;




------------------------------------------------------------------------------------------------------------


MAX => 2014-02-11 06:25:31.817000000
MIN => 2014-01-11 06:25:02.925000000


------------------------------------------------------------------------------------------------------------

-- active sessions 

drop table if exists xls_sessions_sync;

create table xls_sessions_sync(
	type string,
	ini_timeslot double, -- (t_ini - min) / 3600
	session_length bigint -- t_fin -  t_ini

) stored as parquet;

-- 'type can be active, noop, offline'


-- active
insert into xls_sessions_sync
select 'active',
(unix_timestamp(t_ini) - unix_timestamp("2014-01-11 06:25:02.925000000")) / 3600 as ini_timeslot , 
(EXTRACT(EPOCH FROM t_fin) * 1000 + extract(millisecond from t_fin)) - (EXTRACT(EPOCH FROM t_ini) * 1000 + extract(millisecond from t_ini)) 
 as session_length -- segons
from xls_traces_sync_session_count_XX
where hit > 0
order by ini_timeslot;


-- noop
insert into xls_sessions_sync
select 'noop',
(unix_timestamp(t_ini) - unix_timestamp("2014-01-11 06:25:02.925000000")) / 3600 as ini_timeslot , 
(EXTRACT(EPOCH FROM t_fin) * 1000 + extract(millisecond from t_fin)) - (EXTRACT(EPOCH FROM t_ini) * 1000 + extract(millisecond from t_ini)) 
 as session_length -- segons
from xls_traces_sync_session_count_XX
where hit = 0
order by ini_timeslot;
 
-- offline
insert into xls_sessions_sync
select 'offline',
(unix_timestamp(t_fin) - unix_timestamp("2014-01-11 06:25:02.925000000")) / 3600 as ini_timeslot , 
(EXTRACT(EPOCH FROM t_n) * 1000 + extract(millisecond from t_n)) - (EXTRACT(EPOCH FROM t_fin) * 1000 + extract(millisecond from t_fin)) 
 as session_length -- segons
from xls_traces_sync_session_count_XX 
order by ini_timeslot;


show table stats xls_sessions_sync;




------------------------------------------------------------------------------------------------------------


-- TODOWNLOAD, nose ... estara be de veritat???
-- 3 600 000 ms / hora



export one_ create view



select t, 
t_active/total*100 a_rate, noop/total*100 n_rate, offline/total*100 o_rate, active, noop, offline, t_active, t_noop, t_offline, total from
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
  order by t asc



------------------------------------------------------------------------------------------------------------











 