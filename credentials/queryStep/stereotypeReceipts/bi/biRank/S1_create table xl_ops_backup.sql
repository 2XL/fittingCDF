drop table if exists xl_ops_sync;

create table xl_ops_sync  
( 
 id bigint,-- int not null auto_increment,
 user_id bigint,
 req_t string,
 tstamp timestamp, 
 node_id bigint
) stored as parquet;


insert into xl_ops_sync (id, user_id, req_t,tstamp, node_id) 
select row_number() over(order by tstamp asc)
as id ,user_id, req_t, tstamp, node_id
from xlp_traces_sync -- xl_traces_sync_sd
where t = 'storage_done' and
req_t in ('PutContentResponse', 'GetContentResponse', 'MoveResponse', 'Unlink');

-- select count(*) from xl_ops_sync

compute stats xl_ops_sync;







---


 
 
 drop table if exists xl_traces_sync_p;
-- select * from xlp_traces_sync;
 
 -- sd is storage done;
 create table xl_traces_sync_sd (
  t string,
  tstamp timestamp,
  req_t string,
  node_id bigint,
  user_id bigint
 ) stored as parquet;

insert into xl_traces_sync_sd(t, tstamp, req_t, node_id, user_id)
select t, tstamp, req_t, node_id, user_id from xlp_traces_sync
where t = 'storage_done'  and
req_t in ('PutContentResponse', 'GetContentResponse', 'MoveResponse', 'Unlink');

show table stats xl_traces_sync_sd;

-- explain select row_number() over(order by tstamp asc)
-- as id ,user_id, req_t, tstamp, node_id
-- from xlp_traces_sync
-- where t = 'storage_done' and
-- req_t in ('PutContentResponse', 'GetContentResponse', 'MoveResponse', 'Unlink');

