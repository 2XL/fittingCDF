drop table if exists xl_ops_sync_rank;
create table xl_ops_sync_rank
(
 idx bigint,
 idx_prev bigint,
 user_id bigint,
 req_t string,
 tstamp timestamp,
 node_id bigint
) stored as parquet;


-- more phase

drop table if exists xl_temp;

create table xl_temp(
idx bigint,
user_id bigint,
req_t string,
tstamp timestamp,
node_id bigint) stored as parquet;

insert into xl_temp(idx, user_id, req_t, tstamp, node_id)
select dense_rank() 
  over (partition by user_id order by id) as idx,
	user_id, req_t, tstamp, node_id
from xl_ops_sync;

-- insert 


insert into xl_ops_sync_rank(idx, idx_prev, user_id, req_t, tstamp, node_id)
select idx, idx-1 as idx_prev, user_id, req_t, tstamp , node_id
from xl_temp;

drop table if exists xl_temp;


show table stats xl_ops_sync_rank;









