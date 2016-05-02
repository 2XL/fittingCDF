

# interarivals

# sense els nodes conflictius
# per cada perfil, començar per el sync
# agrupar el tractament per cadas sessió, es a dir sid,user_id





-- 
TODO
obtenir els interarivals, de per stereotip

return profile,op1,op2, => user_id,elapsed_time (mili)


crear taules temporals amb sid, mateix procediment

--



drop table if exists ubuntu_one_tiny;

create table ubuntu_one_tiny(
  tstamp timestamp,
  req_t string,
  node_id bigint,
  user_id bigint,
  sid string
  ) stored as parquet;

insert into ubuntu_one_tiny
select tstamp, req_t, node_id, user_id, sid
from ubuntu_one 
where t = 'storage_done' and req_t in (
	'PutContentResponse', 
	'GetContentResponse',
	'MoveResponse', 
	'Unlink',
	'MakeResponse'
	) and node_id not in (select * from rgp_nid_backlist);

show table stats ubuntu_one_tiny;



-- 

generar particions corresponent amb cada perfil d.usuari


--

drop table if exists u1_tiny_sync;

create table u1_tiny_sync like default.ubuntu_one_tiny;


insert into u1_tiny_sync 
select * from default.ubuntu_one_tiny
where user_id in (select * from xlp_profile_sync);

show table stats u1_tiny_sync



--

indexar les operacions per usuari, sid i ordenats per data

--


drop table if exists u1_tiny_sync_idx;

create table u1_tiny_sync_idx(
	idx bigint,
	tstamp timestamp,
	req_t string,
	node_id bigint,
	user_id bigint,
	sid string
) stored as parquet;

insert into u1_tiny_sync_idx
select  
 dense_rank() over (partition by user_id, sid order by tstamp) as idx, *
from u1_tiny_sync;
  
show table stats u1_tiny_sync_idx;

--

concatenar queires, els queries per cada usuari indexat per user_id, sid, i filtrar els null entre operacions

// TODO REDO!!!! --> ALL!!! [i dle - s ync - b ackup - r egular - c dn]
--


-- avans de pair call generar els rel
drop table if exists u1_tiny_sync_rel;

create table u1_tiny_sync_rel(
  idx bigint,
  idx_prev bigint, 
  tstamp timestamp,
  req_t string, 
  user_id bigint,
  sid string
) stored as parquet;

insert into u1_tiny_sync_rel
  select 
  idx,
  idx-1, 
  tstamp,
  req_t, 
  user_id,
  sid
  from u1_tiny_sync_idx;


-- show table stats u1_tiny_sync_rel;

-- generar els pairs

drop table if exists u1_tiny_sync_pair;

create table u1_tiny_sync_pair
  (
    user_id bigint,
    idx bigint,
    idx_n bigint,
    tstamp timestamp,
    tstamp_n timestamp,
    req_t string,
    req_t_n string 
    ) stored as parquet;



insert into u1_tiny_sync_pair
  select 
    a.user_id,
    a.idx,
    b.idx,
    a.tstamp,
    b.tstamp,
    a.req_t,
    b.req_t
    from u1_tiny_sync_rel a
    left join u1_tiny_sync_rel b 
    on (a.user_id = b.user_id and a.idx = b.idx_prev and a.sid = b.sid)
    where b.user_id is not null; -- ignorar els ultims, sense next

-- show table stats u1_tiny_sync_pair;



-- 

-- amb aixo ja puc generar les estadistiques

--

drop table if exists u1_tiny_sync_raw;

create table u1_tiny_sync_raw (
user_id bigint,
op1 string,
op2 string,
elapsed bigint
) stored as parquet;


-- okey

insert into u1_tiny_sync_raw(user_id, op1, op2, elapsed)
select user_id,
 req_t,
 req_t_n,  
EXTRACT(EPOCH FROM tstamp_n) * 1000 + extract(millisecond from tstamp_n) -
EXTRACT(EPOCH FROM tstamp) * 1000 + extract(millisecond from tstamp) elapsed
from u1_tiny_sync_pair;

show table stats u1_tiny_sync_raw;

 






 



