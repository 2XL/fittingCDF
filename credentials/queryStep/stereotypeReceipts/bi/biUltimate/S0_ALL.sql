

# define: que fa i el que genera a cada step
# aquest modul preten generar els interarivals dels node_id nous








-- milisegons

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
 

-- generar la taula d'interarrival amb tots



-- retrieving all the interarrivals

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
 

-- sync, sync, sync, sync, sync
-- sync, sync, sync, sync, sync


-- retrieving only those of the current month



 


drop table if exists xl_traces_sync_new;

create table xl_traces_sync_new (
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
)stored as parquet;


insert into xl_traces_sync_new
select * from xl_traces_sync_min
where node_id not in 
(
select node_id from xl_traces_sync_min
where req_t = 'MakeResponse' 
);

show table stats xl_traces_sync_new;

-- s ync 	b ackup		c dn		r egular		i dle


** sync EXCEPTION

drop table if exists xl_traces_sync_new;

create table xl_traces_sync_new (
  idx bigint,
  user_id bigint,
  ext string,
  size bigint,
  tstamp timestamp,
  req_t string,
  node_id bigint
)stored as parquet;


insert into xl_traces_sync_new
select * from xl_traces_sync_tiny
where node_id not in 
(
select node_id from xl_traces_sync_tiny
where req_t = 'MakeResponse' 
);

show table stats xl_traces_sync_new;




-- generate result with no derivation...

-- to generate the script 



-- rename the previous table

alter table xl_traces_sync_new rename 
to xl_traces_sync_old;

alter table xl_traces_sync_new rename 
to xl_traces_sync_old;

alter table xl_traces_sync_new rename 
to xl_traces_sync_old;

alter table xl_traces_sync_new rename 
to xl_traces_sync_old;

alter table xl_traces_sync_new rename 
to xl_traces_sync_old;


-- create the new tables




drop table if exists xl_traces_sync_new;

create table xl_traces_sync_new (
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
)stored as parquet;


insert into xl_traces_sync_new
select * from xl_traces_sync_min
where node_id in 
(
select node_id from xl_traces_sync_min
where req_t = 'MakeResponse' 
);

show table stats xl_traces_sync_new;

-- s ync 	b ackup		c dn		r egular		i dle




drop table if exists xl_traces_sync_new_rel;

create table xl_traces_sync_new_rel(
  idx bigint,
  idx_prev bigint,
  idx_rel bigint,
  tstamp timestamp,
  req_t string,
  node_id bigint,
  user_id bigint
) stored as parquet;

insert into xl_traces_sync_new_rel
  select 
  idx,
  idx-1,
  dense_rank() over (partition by user_id, req_t, node_id order by idx) as idx_rel,
  tstamp,
  req_t,
  node_id,
  user_id
  from xl_traces_sync_new;


  show table stats xl_traces_sync_new_rel;





-- add pairwise  *** REDO

drop table if exists xl_traces_sync_new_XX;

create table xl_traces_sync_new_XX
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



insert into xl_traces_sync_new_XX
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
    from xl_traces_sync_new_rel a
    left join xl_traces_sync_new_rel b 
    on (a.user_id = b.user_id and a.idx = b.idx_prev)
    where b.user_id is not null; -- ignorar els ultims, sense next


show table stats xl_traces_sync_new_XX;





-- retrieving all the interarrivals

drop table if exists xl_traces_sync_new_raw;

create table xl_traces_sync_new_raw (
user_id bigint,
op1 string,
op2 string,
nid1 bigint,
nid2 bigint,
elapsed bigint
) stored as parquet;


-- okey

insert into xl_traces_sync_new_raw(user_id, op1, op2, nid1, nid2, elapsed)
select user_id,
 req_t,
 req_t_n, 
node_id,
node_id_n,
unix_timestamp(tstamp_n) - unix_timestamp(tstamp) elapsed
from xl_traces_sync_new_XX;

show table stats xl_traces_sync_new_raw;
 


-- revoke the old
-- NEW


-- select all the traces that exist and belong to certain profile

-- xl_traces_XXXX_new 			<- traces noves / x perfil & created
-- xl_traces_XXXX_new_rel		<- traces noves amb row_number()
-- xl_traces_XXXX_new_xx		<- traces noves amb dense_rank()
-- xl_traces_XXXX_new_raw		<- traces noves paired !!!




-- aux initial step

drop table if exists xl_traces_sync_new_nid;
create table xl_traces_sync_new_nid(
node_id bigint
) stored as parquet;

insert into xl_traces_sync_new_nid
select node_id from xl_traces_sync_tiny -- xl_traces_sync_tiny
where req_t = 'MakeResponse';

show table stats xl_traces_sync_new_nid;



-- xl_traces_XXXX_new 			<- traces noves / x perfil & created

drop table if exists xl_traces_sync_new;

create table xl_traces_sync_new (
  node_id bigint,
  user_id bigint,
  tstamp timestamp,
  req_t string,
)stored as parquet;


insert into xl_traces_sync_new
select node_id, user_id, tstamp, req_t from xl_traces_sync_tiny
where node_id not in 
(
select node_id from xl_traces_sync_tiny -- xl_traces_sync_tiny
where req_t = 'MakeResponse' 
);

show table stats xl_traces_sync_new;








drop table if exists xl_traces_sync_new;

create table xl_traces_sync_new (
  node_id bigint,
  user_id bigint,
  tstamp timestamp,
  req_t string,
)stored as parquet;


insert into xl_traces_sync_new
select node_id, user_id, tstamp, req_t from xl_traces_sync_min
where node_id not in 
(
select node_id from xl_traces_sync_min -- xl_traces_sync_tiny
where req_t = 'MakeResponse' 
);

show table stats xl_traces_sync_new;









-- xl_traces_XXXX_new_rel		<- traces noves amb row_number()

drop table if exists xl_traces_sync_new_rel;

create table xl_traces_sync_new_rel (
  idx, bigint
  node_id bigint,
  user_id bigint,
  tstamp timestamp,
  req_t string,
)stored as parquet;


insert into xl_traces_sync_new_rel
	select 
		row_number() over(partition by user_id order by tstamp asc) idx,
		*
		from xl_traces_sync_new;


show table stats xl_traces_sync_new_rel;
















 













-- // get the markov general_all

select 
  op1,
  op2, 
  count(*) hit, 
  avg(unix_timestamp(op2time) - unix_timestamp(op1time)) elapsed from xl_traces_sync_min_duo
group by op1, op2
order by op1, op2 



select 
  op1,
  op2, 
  count(*) hit, 
  avg((EXTRACT(EPOCH FROM op2time) * 1000 + extract(millisecond from op2time)) - (EXTRACT(EPOCH FROM op1time) * 1000 + extract(millisecond from op1time))) elapsed from xl_traces_sync_min_duo
group by op1, op2
order by op1, op2 



