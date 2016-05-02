
drop table if exists xl_ops_sync_ext;

create table xl_ops_sync_ext
( 
 id bigint,-- int not null auto_increment,
 user_id bigint,
 req_t string,
 tstamp timestamp, 
 node_id bigint
) stored as parquet;


insert into xl_ops_sync_ext (id, user_id, req_t,tstamp, node_id) 
select 
	row_number() over(order by tstamp asc) as id,
	user_id, 
	req_t, 
	tstamp, 
	node_id
from xlp_traces_sync -- xl_traces_sync_sd :: fer una taula intermitja per memory limit
where t = 'storage_done' and
req_t in (
	'PutContentResponse', 
	'GetContentResponse',
	'MoveResponse', 
	'Unlink',
	'MakeResponse'
	);

-- select count(*) from xl_ops_sync

compute stats xl_ops_sync_ext;





-- [sync, sync, sync, sync, sync]

 drop table if exists xl_traces_sync_sd_ext;
-- select * from xlp_traces_sync;
 
 -- sd is storage done;
 create table xl_traces_sync_sd_ext (
  tstamp timestamp,
  req_t string,
  node_id bigint,
  user_id bigint
 ) stored as parquet;

insert into xl_traces_sync_sd_ext(tstamp, req_t, node_id, user_id)
select tstamp, req_t, node_id, user_id from xlp_traces_sync
where t = 'storage_done'  and
req_t in ('PutContentResponse', 
	'GetContentResponse',
	 'MoveResponse',
	  'Unlink',
	'MakeResponse');

show table stats xl_traces_sync_sd_ext;





-- extract only the ones that are interested and index them by timestamp

-- compute stats before computing the following operation


drop table if exists xl_ops_sync_ext;

create table xl_ops_sync_ext
( 
 id int,-- int not null auto_increment,
 user_id bigint,
 req_t string,
 tstamp timestamp, 
 node_id bigint
) stored as parquet;


insert into xl_ops_sync_ext (id, user_id, req_t,tstamp, node_id) 
select 
	row_number() over(order by tstamp asc) as id,
	user_id, 
	req_t, 
	tstamp, 
	node_id
from xl_traces_sync_sd_ext; -- xl_traces_sync_sd :: fer una taula intermitja per memory limit
 
2147483647
4294961014


-- contar las trazas indexar la mitad luego la otra mitad


-- total 319254020 trazas

