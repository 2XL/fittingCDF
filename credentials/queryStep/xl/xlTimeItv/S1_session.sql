1st  

# retrieve all the sessions by user-profile

user_id, t_start, t_finish, elapsed, count() ops

drop table if exists xl_traces_sync_min_raw;

create table xl_traces_sync_min_raw (
user_id bigint,
op1 string,
op2 string,
nid1 bigint,
nid2 bigint,
elapsed bigint
) stored as parquet;


-- okey

insert into xl_traces_sync_min_raw(user_id, op1, op2, nid1, nid2, elapsed)
select user_id,
 req_t,
 req_t_n, 
node_id,
node_id_n,
EXTRACT(EPOCH FROM tstamp_n) * 1000 + extract(millisecond from tstamp_n) -
EXTRACT(EPOCH FROM tstamp) * 1000 + extract(millisecond from tstamp) elapsed
from xl_traces_sync_min_XX;

show table stats xl_traces_sync_min_raw;

 
// --- lo de dalt es demo code


# no viable llamar todo


drop table if exists xls_traces_cdn;

create table xls_traces_cdn (
user_id bigint,
sid string,
logfile_id string,
tstamp timestamp,
req_t string
) stored as parquet;

insert into xls_traces_cdn
select user_id, sid, logfile_id, tstamp, req_t from default.ubuntu_one u1
where 
sid != '' and 
t = 'storage_done' and
user_id in ( select * from xlp_profile_cdn );

show table stats xls_traces_cdn;






## traces -> sessions instead of traces

drop table xls_traces_cdn_session_count;

create table xls_traces_cdn_session_count (
user_id bigint,
sid string,
logfile_id string,
ini timestamp,
fin timestamp,
hit_make bigint,
hit_get bigint,
hit_put bigint,
hit_unlink bigint,
hit_move bigint,
) stored as parquet;


insert into xls_traces_cdn_session_count
select 
	user_id, 
	sid, 
	logfile_id, 
	min(tstamp) ini, 
	max(tstamp) fin, 
	sum(case when req_t = 'MakeResponse' then 1 else 0 end) hitMake,
	sum(case when req_t = 'GetContentResponse' then 1 else 0 end) hitGet,
	sum(case when req_t = 'PutContentResponse' then 1 else 0 end) hitPut,
	sum(case when req_t = 'Unlink' then 1 else 0 end) hitUnlink,
	sum(case when req_t = 'MoveResponse' then 1 else 0 end) hitMove 
from xls_traces_cdn
group by user_id, sid, logfile_id;

show table stats xls_traces_cdn_session_count;