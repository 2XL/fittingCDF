drop table if exists xl_ops_sync_pair;

create table xl_ops_sync_pair
(
  user_id bigint,
  idx bigint,
  idx_next bigint,
  req_t string,
  req_t_next string,
  tstamp timestamp,
  tstamp_next timestamp,
  node_id bigint,
  node_id_next bigint
) stored as parquet;

insert into xl_ops_sync_pair(user_id, idx, idx_next, req_t, req_t_next, tstamp, tstamp_next, node_id, node_id_next)
select a.user_id, 
a.idx as idx, b.idx as idx_next, 
a.req_t as req_t, b.req_t as req_t_next, 
a.tstamp as tstamp, b.tstamp as tstamp_next, a.node_id as node_id, b.node_id as node_id_next
from xl_ops_sync_rank a 
left join xl_ops_sync_rank b on ( a.user_id = b.user_id and a.idx = b.idx_prev)
where b.user_id is not null;

show table stats xl_ops_sync_pair;
