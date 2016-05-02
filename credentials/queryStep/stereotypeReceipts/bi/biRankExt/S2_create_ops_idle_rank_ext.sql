


create table xl_ops_idle_ext_rank( 
  idx bigint, -- ops current
  idx_op bigint, -- ops current relative idx, by req_t and node_id
  user_id bigint, -- who
  req_t string,
  tstamp timestamp
  node_id bigint
  ) stored as parquet;

 

insert into xl_ops_idle_ext_rank
select 
dense_rank() over (partition by user_id order by id) as idx, 	
dense_rank() over (partition by user_id, req_t, node_id order by id) as idx_op, 
user_id, 
req_t, 
tstamp, 
node_id
from xl_ops_idle_ext;











insert into xl_ops_idle_rank_ext;

-- [sync, backup, regular, idle, cdn]