
drop table if exists ubuntu_one_min;

create table ubuntu_one_min(
  ext string,
  size bigint,
  tstamp timestamp,
  req_t string,
  node_id bigint,
  user_id bigint,
  udfs bigint,
  shares int,
  vol_id bigint
  ) stored as parquet;

insert into ubuntu_one_min
select ext, size, tstamp, req_t, node_id, user_id, udfs, shares, vol_id
from ubuntu_one 
where t = 'storage_done' and req_t in (
	'PutContentResponse', 
	'GetContentResponse',
	'MoveResponse', 
	'Unlink',
	'MakeResponse'
	) and node_id not in (select * from rgp_nid_backlist);

show table stats ubuntu_one_min;



-- regular, sync, sync




-- insert as partitions...

-- tornar a crear les taules temporals de operacions... per perfil

-- xl_traces_sync_min

drop table if exists xl_traces_sync_min;


create table xl_traces_sync_min(
  idx bigint,
  ext string,
  size bigint,
  tstamp timestamp,
  req_t string,
  node_id bigint,
  user_id bigint,
  udfs bigint,
  shares int,
  vol_id bigint
) stored as parquet;


insert into xl_traces_sync_min 
select row_number() over(partition by user_id order by tstamp asc) idx,
 *
 from default.ubuntu_one_min
where user_id in (select * from xlp_profile_sync);

show table stats xl_traces_sync_min;




--- ******************************************************

drop table if exists xl_traces_sync_tiny;

create table xl_traces_sync_tiny (
  idx bigint,
  user_id bigint, 
  ext string,
  size bigint,
  tstamp timestamp,
  req_t string,
  node_id bigint
) stored as parquet;
insert into xl_traces_sync_tiny
select 
row_number() over(partition by user_id order by tstamp asc) idx,
user_id, ext, size, tstamp, req_t, node_id
 from default.ubuntu_one_min
where user_id in (select * from xlp_profile_sync);

show table stats xl_traces_sync_tiny;












--
drop table if exists xl_traces_sync_min_rel;

create table xl_traces_sync_min_rel(
  idx bigint,
  idx_prev bigint,
  idx_rel bigint,
  tstamp timestamp,
  req_t string,
  node_id bigint,
  user_id bigint
) stored as parquet;

insert into xl_traces_sync_min_rel
  select 
  idx,
  idx-1,
  dense_rank() over (partition by user_id, req_t, node_id order by idx) as idx_rel,
  tstamp,
  req_t,
  node_id,
  user_id
  from xl_traces_sync_tiny;


  show table stats xl_traces_sync_min_rel;









-- **** KO 











drop table if exists xl_traces_sync_part;

create table xl_traces_sync_part (
  ext string,
  size bigint,
  tstamp timestamp,
  req_t string,
  node_id bigint
) partitioned by (user_id bigint) stored as parquet;

insert into xl_traces_sync_part partition(user_id)
select * from xl_traces_sync_tiny;

show table stats xl_traces_sync_part;


 
insert into xl_traces_sync_part(user_id, ext, size, tstamp, req_t, node_id) 
select user_id, ext, size, tstamp, req_t, node_id from xl_traces_sync_min;
 






insert into xl_traces_sync_part partition(user_id = )
select row_number() over(partition by user_id order by tstamp asc) idx, *
 from default.ubuntu_one_min
where user_id in (select * from xlp_profile_sync);





















-- RE-CREATE: the tables but partitioned

  --                MIN                 REL
i dle     --     3.73 MB            4.29 MB
r egular  -- 1.15     GB            1.33 GB
b ackup   --   902.18 MB            1.07 GB
c dn      --   305.09 MB          327.24 MB

s ync     -- memory limit hitted


// crearte by 2 or 3 steps... sync users a, b, c, then join them



-- add additional layer of resolution


drop table if exists xl_traces_sync_min_rel;

create table xl_traces_sync_min_rel(
  idx bigint,
  idx_prev bigint,
  idx_rel bigint,
  tstamp timestamp,
  req_t string,
  node_id bigint,
  user_id bigint
) stored as parquet;

insert into xl_traces_sync_min_rel
  select 
  idx,
  idx-1,
  dense_rank() over (partition by user_id, req_t, node_id order by idx) as idx_rel,
  tstamp,
  req_t,
  node_id,
  user_id
  from xl_traces_sync_min;


  show table stats xl_traces_sync_min_rel;




-- add pairwise  *** REDO

drop table if exists xl_traces_sync_min_XX;

create table xl_traces_sync_min_XX
  (
    user_id bigint,
    idx bigint,
    idx_n bigint,
    tstamp timestamp,
    tstamp_n timestamp,
    req_t string,
    req_t_n string,
    node_id bigint,
    node_id_n bigint,
    idx_rel bigint,
    idx_rel_n bigint
    ) stored as parquet;



insert into xl_traces_sync_min_XX
  select 
    a.user_id,
    a.idx,
    b.idx,
    a.tstamp,
    b.tstamp,
    a.req_t,
    b.req_t,
    a.node_id,
    b.node_id,
    a.idx_rel,
    b.idx_rel
    from xl_traces_sync_min_rel a
    left join xl_traces_sync_min_rel b 
    on (a.user_id = b.user_id and a.idx = b.idx_prev)
    where b.user_id is not null; -- ignorar els ultims, sense next


show table stats xl_traces_sync_min_XX;

-- add trio

drop table if exists xl_traces_sync_min_XXX;

create table xl_traces_sync_min_XXX
  (
    user_id bigint,
    idx bigint,
    idx_n bigint,
    idx_l bigint,
    tstamp timestamp,
    tstamp_n timestamp,
    tstamp_l timestamp,
    req_t string,
    req_t_n string,
    req_t_l string,
    node_id bigint,
    node_id_n bigint,
    node_id_l bigint,
    idx_rel bigint,
    idx_rel_n bigint,
    idx_rel_l bigint
    ) stored as parquet;



insert into xl_traces_sync_min_XXX
  select 
    a.user_id,
    a.idx,
    a.idx_n,
    b.idx,
    a.tstamp,
    a.tstamp_n,
    b.tstamp,
    a.req_t,
    a.req_t_n,
    b.req_t,
    a.node_id,
    a.node_id_n,
    b.node_id,
    a.idx_rel,
    a.idx_rel_n,
    b.idx_rel
    from xl_traces_sync_min_XX a
    left join xl_traces_sync_min_rel b 
    on (a.user_id = b.user_id and a.idx_n = b.idx_prev)
    where b.user_id is not null; -- ignorar els ultims, sense next
 
show table stats xl_traces_sync_min_XXX;


-- Final Parse :D





drop table if exists xl_traces_sync_min_duo;

create table xl_traces_sync_min_duo (
user_id bigint,
op1 string,
op2 string,
op1time timestamp,
op2time timestamp
) stored as parquet;


-- okey

insert into xl_traces_sync_min_duo(user_id, op1, op2, op1time, op2time)
select user_id,
case 
when 'PutContentResponse' = req_t_n and req_t = req_t_n and node_id = node_id_n
then 'Sync'
else req_t_n
end as op1,
case 
when 'PutContentResponse' = req_t_l and req_t_l = req_t_n and node_id_n = node_id_l 
then 'Sync' -- restrictive  
else req_t_l -- rest
end as op2,
tstamp_n,
tstamp_l
from xl_traces_sync_min_XXX;

show table stats xl_traces_sync_min_duo;



-- report stats :



select * from xl_traces_sync_min_duo


select 
  op1,
  op2, 
  count(*) hit, 
  avg(unix_timestamp(op2time) - unix_timestamp(op1time)) elapsed from xl_traces_sync_min_duo
group by op1, op2
order by op1, op2 

-- elapsed en milisegons

-- inner join with it selve and pairwise operation 





/*
drop table if exists xl_traces_sync_prq;

create table xl_traces_sync_prq(
  idx int,
  ext string,
  size bigint,
  tstamp timestamp,
  req_t string,
  node_id bigint,
  udfs bigint,
  shares int,
  vol_id bigint
) partitioned by (user_id bigint) stored as parquet;

insert overwrite xl_traces_sync_prq partition(user_id) 
select row_number() over(order by tstamp asc) idx, * from xl_traces_sync_min;
*/

-- insert overwrite
 
