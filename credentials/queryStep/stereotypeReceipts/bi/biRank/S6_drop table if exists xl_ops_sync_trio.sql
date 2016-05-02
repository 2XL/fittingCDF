

---------------------------/// PART1
-- prepare structure

drop table if exists xl_ops_sync_trio;

create table xl_ops_sync_trio(
  user_id bigint,
  idx bigint,
  idx_next bigint,
  idx_last bigint,
  req_t string,
  req_t_next string,
  req_t_last string,
  tstamp timestamp,
  tstamp_next timestamp,
  tstamp_last timestamp,
  node_id bigint,
  node_id_next bigint,
  node_id_last bigint
) stored as parquet;


insert into xl_ops_sync_trio(user_id, idx, idx_next, idx_last, req_t, req_t_next, req_t_last, tstamp, tstamp_next, tstamp_last, node_id, node_id_next, node_id_last)
select a.user_id, a.idx, a.idx_next, b.idx as idx_last, a.req_t, a.req_t_next, b.req_t as req_t_last, a.tstamp, a.tstamp_next, b.tstamp as tstamp_last, a.node_id, a.node_id_next, b.node_id as node_id_last
from xl_ops_sync_pair a 
left join xl_ops_sync_rank b on ( a.user_id = b.user_id  and a.idx_next = b.idx_prev);
-- where b.user_id is not null; -- conservar els nulls 



show table stats xl_ops_sync_trio;


------------------/// PART2
 

-- update operations
-- select * from xl_ops_sync_trio
-- where req_t = 'PutContentResponse' and 
-- req_t = req_t_next and node_id = node_id_next

-- select * from xl_ops_sync_trio
-- where req_t = 'PutContentResponse' and req_t = req_t_next and node_id = node_id_next

drop table if exists xl_ops_sync_duo;

create table xl_ops_sync_duo (
user_id bigint,
op1 string,
op2 string,
op1time timestamp,
op2time timestamp,
op1node bigint,
op2node bigint
) stored as parquet;

-- okey

insert into xl_ops_sync_duo(user_id, op1, op2, op1time, op2time, op1node, op2node)
select user_id,
case 
when 'PutContentResponse' = req_t and req_t = req_t_next and node_id = node_id_next
then 'Update'
else req_t
end as op1,

case 
when 'PutContentResponse' = req_t and req_t = req_t_next and node_id = node_id_next and
    node_id = node_id_last and req_t = req_t_last
	then 'Update' -- restrictive
when 'PutContentResponse' = req_t and req_t = req_t_next and node_id = node_id_next 
	then req_t_last -- less restrictive
else req_t_next -- rest
end as op2,

case 
when 'PutContentResponse' = req_t and req_t = req_t_next and node_id = node_id_next
then tstamp_next
else tstamp
end as op1time,

case 
when 'PutContentResponse' = req_t and req_t = req_t_next and node_id = node_id_next
then tstamp_last
else tstamp_next
end as op2time,

node_id as op1node, 

case 
when 'PutContentResponse' = req_t and req_t = req_t_next and node_id = node_id_next
then node_id_last
else node_id_next

end as op2node
from xl_ops_sync_trio;

show table stats xl_ops_sync_duo;


select op1, op2, count(*) from xl_ops_sync_duo
group by op1, op2

-- [TODO] delete those rows where op2 is NULL

-- from xl_ops_XXXX_trio

-- una quarta taula final amb els camps update...


