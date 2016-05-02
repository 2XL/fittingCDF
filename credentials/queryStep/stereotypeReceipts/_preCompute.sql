

SELECT user_id, node_id, size, tstamp, vol_id FROM ubuntu_one
where t = 'storage_done' and size > 0 and req_t = 'GetContentResponse'
-- req_t = 'GetContentResponse'
-- req_t = 'PutContentResponse'
-- group by req_t




select from_gen, current_gen, ext, hash, mime, node_id, req_t, shared_by, shared_to, size, tstamp, type,  udfs, user_id
from default.ubuntu_one
where t = 'storage_done'



create table ubuntu_one_profiling(
  tstamp timestamp,
  req_t string,
  node_id bigint,
  user_id bigint,
  sid string
  ) stored as parquet;

create table ubuntu_one_profiling(
from_gen string,
current_gen string,
ext string,
hash string,
mime string,
node_id bigint,
req_t string,
shared_by bigint,
shared_to bigint,
size bigint,
tstamp timestamp,
type string,
udfs int,
user_id  bigint
) stored as parquet;


-- columnas

insert into ubuntu_one_profiling(from_gen, current_gen,  ext, hash, mime, node_id, req_t, shared_by, shared_to, size, tstamp, type,  udfs, user_id)
select from_gen, current_gen,  ext, hash, mime, node_id, req_t, shared_by, shared_to, size, tstamp, type,  udfs, user_id
from default.ubuntu_one -- limit 1000
where t = 'storage_done'
and req_t in ('PutContentResponse', 'GetContentResponse', 'MoveResponse', 'Unlink', 'MakeResponse');
show table stats ubuntu_one_profiling;

-- tenemos una tabla temporal de 10GB

drop table if exists ubuntu_one_profiling_sid;

create table ubuntu_one_profiling_sid(
mime string,
node_id bigint,
req_t string,
sid string,
size bigint,
tstamp timestamp,
type string,
user_id  bigint
) stored as parquet;

insert into ubuntu_one_profiling_sid(mime, node_id, req_t, sid, size, tstamp, type, user_id)
select                               mime, node_id, req_t, sid, size, tstamp, type, user_id
from default.ubuntu_one -- limit 1000
where t = 'storage_done'
and req_t in ('PutContentResponse', 'GetContentResponse', 'MoveResponse', 'Unlink', 'MakeResponse');

show table stats ubuntu_one_profiling_sid;




-- distintos request type

select distinct(req_t) from default.ubuntu_one

--GET COUNTER
  drop table if exists u1user_count_get;
  create table u1user_count_get(
  user_id bigint,
  get bigint
  ) stored as parquet;
  insert into u1user_count_get
  select user_id, count(*) get from u1profile.ubuntu_one_profiling where req_t = 'GetContentResponse' group by user_id
--PUT COUNTER
  drop table if exists u1user_count_put;
  create table u1user_count_put(
  user_id bigint,
  put bigint
  ) stored as parquet;
  insert into u1user_count_put
  select user_id, count(*) put from u1profile.ubuntu_one_profiling where req_t = 'PuttContentResponse' group by user_id
--UNIQUE FILES
  drop table if EXISTS u1user_count_fileunique;
  create table u1user_count_fileunique(
  user_id bigint,
  file bigint
  ) stored as parquet;
  insert into u1user_count_fileunique
  select user_id, count(distinct node_id) file from u1profile.ubuntu_one_profiling group by user_id;

-- JOIN THE THE COLUMNS
  drop table if EXISTS u1user_count_specs;
  create table u1user_count_specs(
  user_id bigint,
  file bigint,
  put bigint,
  get bigint
  ) stored as parquet;
  insert into u1user_count_specs


-- one merge
(select cf.user_id, file, (case when put is Null then 0 else put end) put
from u1user_count_fileunique as cf  full outer join u1user_count_put as cp on cf.user_id = cp.user_id)

-- two merge
select cfp.user_id, file, put,
(case when get is Null then 0 else get end) get
from ( select cf.user_id, file, (case when put is Null then 0 else put end) put
from u1user_count_fileunique as cf  full outer join u1user_count_put as cp on cf.user_id = cp.user_id
) as cfp full outer join u1user_count_get as cg on cfp.user_id = cg.user_id



-- extraer numero de puts, gets y ficheros unicos
select count (*)  from u1user_count_fileunique; -- 176767
select count (*)  from u1user_count_put;        -- 147817
select count (*)  from u1user_count_get;        --  86805
select count (*)  from u1user_count_specs;      -- 176767



-- profile backup
-- profile download
-- profile sync

drop table if exists u1user_profile
create table u1user_profile(
user_id bigint, file bigint, put bigint, get bigint, profile string
) stored as parquet;
insert into u1user_profile
select user_id, file, put, get,
'backup' from
(select *,
(case when get * 1000 < put then 1 else 0 end) isBackup,
(case when put * 1000 < get then 1 else 0 end) isDownload,
(case when put > 2 * file  then 1 else 0 end) isSync
from u1user_count_specs) as t
where isBackup = 1;
-- es perd massa precisió

insert into u1user_profile
select user_id, file, put, get,
'download' from
(select *,
(case when get * 1000 < put then 1 else 0 end) isBackup,
(case when put * 1000 < get then 1 else 0 end) isDownload,
(case when put > 2 * file  then 1 else 0 end) isSync
from u1user_count_specs) as t
where isDownload = 1;

insert into u1user_profile
select user_id, file, put, get,
'sync' from
(select *,
(case when get * 1000 < put then 1 else 0 end) isBackup,
(case when put * 1000 < get then 1 else 0 end) isDownload,
(case when put > 2 * file  then 1 else 0 end) isSync
from u1user_count_specs) as t
where isSync = 1;

--

select count(*) from u1user_profile; -- 126685
select count(*) from u1user_profile where profile = "backup";   -- 84581
select count(*) from u1user_profile where profile = "download"; -- 23008
select count(*) from u1user_profile where profile = "sync";     -- 19096






-- CARACTERIZAR FICHEROS DE USUARIOS

-- fase 0 sparar las trazas por grupo de usuarios

drop table if exists ubuntu_one_only_backup;
drop table if exists ubuntu_one_only_download;
drop table if exists ubuntu_one_only_sync;


create table ubuntu_one_only_backup like ubuntu_one_profiling;
create table ubuntu_one_only_download like ubuntu_one_profiling;
create table ubuntu_one_only_sync like ubuntu_one_profiling;


insert into ubuntu_one_only_backup
select op.* FROM ubuntu_one_profiling op inner join (select user_id from u1user_profile where profile = 'backup') as bp on op.user_id = bp.user_id;


insert into ubuntu_one_only_download
select op.* FROM ubuntu_one_profiling op inner join (select user_id from u1user_profile where profile = 'download') as dp on op.user_id = dp.user_id;


insert into ubuntu_one_only_sync
select op.* FROM ubuntu_one_profiling op inner join (select user_id from u1user_profile where profile = 'sync') as sp on op.user_id = sp.user_id;
--
-- select count(*) from ubuntu_one_profiling;   -- 258584155
select count(*) from ubuntu_one_only_backup;    -- 184518054
select count(*) from ubuntu_one_only_download;  --  15234235
select count(*) from ubuntu_one_only_sync;      --  58831866




-- okey

insert into u1_tiny_sync_raw(user_id, op1, op2, elapsed)
select user_id,
 req_t,
 req_t_n,
EXTRACT(EPOCH FROM tstamp_n) * 1000 + extract(millisecond from tstamp_n) -
EXTRACT(EPOCH FROM tstamp) * 1000 + extract(millisecond from tstamp) elapsed
from u1_tiny_sync_pair;

show table stats u1_tiny_sync_raw;


[ubuntu_one_only_XXXX, download, backup, sync]
select type, count(*) from  ubuntu_one_only_XXXX
group by type



select type, count(*) hit from  ubuntu_one_only_download group by type
 	type	    hit
0	Directory	147351
1	File	    1336311
2		        13750573


select type, count(*) hit from  ubuntu_one_only_sync group by type
 	type	hit
0	Directory	469179
1	File	    7805498
2		        50557189

select type, count(*) hit from  ubuntu_one_only_backup group by type
0	Directory	8942919
1	File	    88022043
2		        87553092





-- select regexp_replace(mime, 'u+', ''), count(*) hit
-- from ubuntu_one_only_download
-- group by mime
-- order by hit desc

-- select type, count(*) hit from  ubuntu_one_only_backup group by type



select
regexp_extract(mime, '.*?/(.*?)\'', 1 ) as none_multipart,
regexp_extract(mime, '.*?\'(.*?)/.*?', 1) as multipart,
count(*) hit,
sum(size),
-- STDDEV(size),
-- VARIANCE(size),
-- appx_median(size),
-- min(size),
-- max(size),
from ubuntu_one_only_download
where size is not null
group by mime
order by hit desc




-- create the tables again replacing null
create table ubuntu_one_only_backup_nn like ubuntu_one_only_backup;
create table ubuntu_one_only_download_nn like ubuntu_one_only_download;
create table ubuntu_one_only_sync_nn like ubuntu_one_only_sync;


insert into ubuntu_one_only_backup_nn
select from_gen, current_gen,	ext, hash, mime, node_id, req_t, shared_by, shared_to, (case when size is null then 0 else size end) size, tstamp, type, udfs, user_id
from ubuntu_one_only_backup;

-- insert into ubuntu_one_only_download_nn
-- select from_gen, current_gen,	ext, hash, mime, node_id, req_t, shared_by, shared_to, (case when size is null then 0 else size end) size, tstamp, type, udfs, user_id
-- from ubuntu_one_only_download;
-- insert into ubuntu_one_only_sync_nn
-- select from_gen, current_gen,	ext, hash, mime, node_id, req_t, shared_by, shared_to, (case when size is null then 0 else size end) size, tstamp, type, udfs, user_id
-- from ubuntu_one_only_sync;

show table stats ubuntu_one_only_backup_nn
select count(*) from ubuntu_one_only_backup_nn;    -- 184518054
select count(*) from ubuntu_one_only_download_nn;  --  15234235
select count(*) from ubuntu_one_only_sync_nn;      --  58831866

-- nn states as not null



-- generar taules per perfil =>  script per extreure els csv
select
regexp_extract(mime, '.*?/(.*?)\'', 1 ) as none_multipart,
regexp_extract(mime, '.*?\'(.*?)/.*?', 1) as multipart,
count(*) hit,
sum(size) size
-- STDDEV(size),
-- VARIANCE(size),
-- appx_median(size),
-- min(size),
-- max(size),
from ubuntu_one_only_download_nn
group by mime
order by size desc



-- CREATE table with file and mime

-- select * from ubuntu_one_profiling where req_t = "MakeResponse"
create table u1file_mime like ubuntu_one_profiling;
insert into u1file_mime
select * from ubuntu_one_profiling where mime != "None" and mime != ""



-- 1249953491



                                  -- ops       # distinct
select count(*) from u1file_mime  -- 118929449 # 95716028

select count(*) from u1file_mime  --  80666516 # 76748329
where req_t = "MakeResponse"

select count(*) from u1file_mime  --  33740953 # 33478059
where req_t = "Unlink"

select count(*) from u1file_mime  --   4521980 #  4088549
where req_t = "MoveResponse"

select count(distinct(node_id)) from u1file_mime
where req_t = "MoveResponse"


drop table if exists u1file_mime_unique;
create table u1file_mime_unique like u1file_mime; -- u1file_mime_unique
insert into u1file_mime_unique
select um.* from u1file_mime as um inner join (select node_id from u1file_mime group by node_id) as uid on um.node_id = uid.node_id


create table ubuntu_one_only_backup_ext LIKE ubuntu_one_only_backup;
insert into ubuntu_one_only_backup_ext
select uoob.from_gen, uoob.current_gen,	u1mu.ext, uoob.hash, u1mu.mime, uoob.node_id, uoob.req_t, uoob.shared_by, uoob.shared_to, uoob.size, uoob.tstamp, uoob.type, uoob.udfs, uoob.user_id
from ubuntu_one_only_backup as uoob inner join u1file_mime_unique as u1mu


--- POST PONE MEMORY LEAK


-- download
drop table if EXISTS u1file_mime_hit_download;
create table u1file_mime_hit_download(none_multipart string, multipart string, hit bigint) stored as parquet;

insert into u1file_mime_hit_download
select
regexp_extract(mime, '.*?/(.*?)\'', 1 ) as none_multipart,
regexp_extract(mime, '.*?\'(.*?)/.*?', 1) as multipart,
count(*) hit
-- STDDEV(size),
-- VARIANCE(size),
-- appx_median(size),
-- min(size),
-- max(size),
from ubuntu_one_only_download
group by mime


-- backup
drop table if EXISTS u1file_mime_hit_backup;
create table u1file_mime_hit_backup(none_multipart string, multipart string, hit bigint) stored as parquet;

insert into u1file_mime_hit_backup
select
regexp_extract(mime, '.*?/(.*?)\'', 1 ) as none_multipart,
regexp_extract(mime, '.*?\'(.*?)/.*?', 1) as multipart,
count(*) hit
-- STDDEV(size),
-- VARIANCE(size),
-- appx_median(size),
-- min(size),
-- max(size),
from ubuntu_one_only_backup
group by mime



-- sync

drop table if EXISTS u1file_mime_hit_sync;
create table u1file_mime_hit_sync(none_multipart string, multipart string, hit bigint) stored as parquet;

insert into u1file_mime_hit_sync
select
regexp_extract(mime, '.*?/(.*?)\'', 1 ) as none_multipart,
regexp_extract(mime, '.*?\'(.*?)/.*?', 1) as multipart,
count(*) hit
-- STDDEV(size),
-- VARIANCE(size),
-- appx_median(size),
-- min(size),
-- max(size),
from ubuntu_one_only_sync
group by mime







-- select * from u1file_mime_hit_sync
-- where multipart = 'chemical'
-- order by hit desc


--
create table u1user_sync(user_id bigint) stored as parquet ;
insert into u1user_sync
select user_id from u1user_profile where profile = 'sync';

create table u1user_download(user_id bigint) stored as parquet ;
insert into u1user_download
select user_id from u1user_profile where profile = 'download';



drop table if exists u1file_type_prob_freq_download;
create table u1file_type_prob_freq_download(multipart string, hit bigint) stored as parquet;
insert into u1file_type_prob_freq_download
select multipart, sum(hit) hit
from u1file_mime_hit_download
group by multipart


--
--
create table u1file_mime_unique like u1file_mime;
insert into u1file_mime_unique
select from_gen, current_gen, ext, hash, mime, node_id, req_t, shared_by, shared_to, size, tstamp, type, udfs, user_id from (
select rank() over(partition by node_id order by tstamp) as rank, *
from u1file_mime
) as t where rank = 1
-- this proposal is not good because the tstamp can be the same and there would be more than one instance with rank 1
select * from default.ubuntu_one
where node_id = 1249953491;
--


select count(*) from
u1file_mime_unique -- 95716053

u1file_mime        -- 118929449


--
fix the duplicated traces
--

create table u1file_mime_sid like ubuntu_one_profiling_sid;
insert into u1file_mime_sid
select * from ubuntu_one_profiling_sid where mime != "None" and mime != ""

drop table if EXISTS  u1file_mime_unique_sid;
create table u1file_mime_unique_sid like u1file_mime_sid;
insert into u1file_mime_unique_sid
select mime, node_id, req_t, sid, size, tstamp, type, user_id from (
select rank() over(partition by node_id order by tstamp, sid) as rank, *
from u1file_mime_sid
) as t where rank = 1

-- per comprobar que no hiha overlapping


select node_id, count(*) hit from u1file_mime_unique_sid
group by node_id order by hit DESC

-- OKEY!!
-- fet que siguin unics


  -- select node_id, count(*) hit from u1file_mime_unique_sid group by node_id order by hit DESC


  -- alter table u1file_mime_hit_download rename to u1file_mime_ops_hit_download

  -- create table u1file_profile_backup_mime(none_multipart string, multipart string, node_id bigint) stored as parquet;
  insert into u1file_profile_backup_mime
   select
  regexp_extract(mime, '.*?/(.*?)\'', 1 ) as none_multipart,
  regexp_extract(mime, '.*?\'(.*?)/.*?', 1) as multipart,
  node_id
  from u1file_mime_unique_sid fmus inner join u1user_type_backup ut on fmus.user_id = ut.user_id
  -- todos los archivos del tipo backup

  insert into u1file_profile_download_mime
   select
  regexp_extract(mime, '.*?/(.*?)\'', 1 ) as none_multipart,
  regexp_extract(mime, '.*?\'(.*?)/.*?', 1) as multipart,
  node_id
  from u1file_mime_unique_sid fmus inner join u1user_type_download ut on fmus.user_id = ut.user_id
  -- todos los archivos del tipo download


  insert into u1file_profile_sync_mime
   select
  regexp_extract(mime, '.*?/(.*?)\'', 1 ) as none_multipart,
  regexp_extract(mime, '.*?\'(.*?)/.*?', 1) as multipart,
  node_id
  from u1file_mime_unique_sid fmus inner join u1user_type_sync ut on fmus.user_id = ut.user_id
  -- todos los archivos del tipo sync


create table u1file_size(
  node_id bigint,
  max bigint,
  min bigint,
  edits bigint
  ) stored as parquet;

insert into u1file_size
select node_id, max(size) max, min(size) min, count(*) edits from (select * from ubuntu_one_profiling_sid  where size >= 0) as t  group by node_id -- order by hit desc


create table u1file_size_diff(
 node_id bigint,
  max bigint,
  min bigint,
  edits bigint,
  diff bigint
  ) stored as parquet;

  insert into u1file_size_diff
select *, (max-min) diff from u1file_size -- order by diff desc




select * FROM u1file_size_diff order by diff desc


-- ahora dispongo de una tabla

>



-- crear distribució de multipart per fitchers unics

select count(*)
from u1file_mime_unique as ufmu
inner join u1user_type_backup uutb on ufmu.user_id = uutb.user_id



















-- tabla con

-- contar numero de uploads , downloads, ficheros unicos


T: trace type. Distinct types of traces have different columns associated.
addr: Inbound address and port. Probably not particularly interesting, as they'll be internal addresses.
caps: the caps of a client. Newer clients will have more capabilities than older ones. It's like feature flags. This allow U1 to distinguish which clients can do certain actions, and even to notify a client about the necessity of updating his client.
client_metadata: metadata of a client. For example, operating system, client build information, etc.
current_gen: current volume generation. A volume's generation is a monotonic counter increased for every operation on the volume. It is needed for clients to detect changes between the server version and their own.
ext: file extension.
failed: error message (if any).
free_bytes: available space in the volume.
from_gen: client generation. This is for an operation that requests all the changes to a volume from a certain generation onwards. The client keeps track of the generation it's at, and on reconnection asks for changes from that point on.
hash: sha1sum of the file
level: trace level.
logfile_id: trace file identifier.
method: rpc method name.
mime: file type.
msg: request message.
node_id: id a file or a directory.
nodes: is the number of files and directories within a volume.
pid: # of server process.
req_id: request identifier. There are separate entries for the start and end of every operation. `req_id` is a unique identifier for this server and session, where the server is part of the logfile_id (without date).  `req_id` is present in entries of type `storage` and `storage_done` (specialization of storage). ‘Storage’ requests are also specialization of ‘Session’.
req_t: request type.
root: root of the volume. All volumes have a root node that would be similar to the mount point in a file system.
server: server type.
shared_by: owner of the shared volume.
shared_to: user to which the shared folder is shared with.
shares: number of shared volumes for this user.
sid: id of the ubuntuone-storageprotocol session (not http).
size: file size.
time: request processing time (database processing).
tstamp: trace timestamp.
type: node type (here we can distinguish between files and directories).
udfs: number of user volumes.
user_id: user identifier.
user: user name (anonymized using int32 random numbers). Only used when the users starts a session.
vol_id: volume identifier. "0" is the identifier of the root volume for users. This means that all the users have a volume with vol_id=0.







t	addr	caps	client_metadata	current_gen	ext	failed	free_bytes	from_gen	hash	level	logfile_id	method	mime	msg	node_id	nodes	pid	req_id	req_t	root	server	shared_by	shared_to	shares	sid	size	time	tstamp	type	udfs	user_id	user	vol_id

rpc							NULL			INFO	production-treesorrel-13-20140207	dal.unlink_node		ended OK	NULL	NULL	14868	NULL		NULL	storage.server.rpc.client	NULL	NULL	NULL		NULL	0.0539121627808	2014-02-06 07:53:13.880000000		NULL	1990605368	NULL	NULL
storage	127.0.0.1:41740						NULL			INFO	production-whitecurrant-9-20140207			Request being scheduled	NULL	NULL	16567	5205	GetContentResponse	NULL	storage.server	NULL	NULL	NULL	c2f8077d-1e38-403a-8083-b5cedc215bdd	NULL	NULL	2014-02-06 07:53:13.880000000		NULL	737275140	NULL	NULL
storage_done	127.0.0.1:56965				jpg		NULL		0	INFO	production-treesorrel-13-20140207		u'image/jpeg'	Request done	2063645832	NULL	14868	20305	Unlink	0	storage.server	0	0	NULL	634ba5a7-0416-4c8d-8cc5-666429c62238	NULL	NULL	2014-02-06 07:53:13.881000000	File	NULL	352920644	NULL	2810527775
rpc							NULL			INFO	production-treesorrel-13-20140207	dal.unlink_node		started	NULL	NULL	14868	NULL		NULL	storage.server.rpc.client	NULL	NULL	NULL		NULL	NULL	2014-02-06 07:53:13.882000000		NULL	1990605368	NULL	NULL


-----------


create table u1trace_download_mime(
  node_id bigint,
  req_t string,
  size bigint,
  tstamp timestamp,
  type string,
  user_id bigint
  ) stored as parquet



select * from u1trace_download

-----------

* paso cero => u1file_nid_uid_mime_size

create table u1file_nid_uid_mime_size(
node_id bigint,
user_id bigint,
multipart string,
none_multipart string,
size string
) stored as parquet;


------------

=> 	node_id	max	min	edits	diff :: fmu
u1file_size_diff [node_id, max_size, min_size, operations(can  be make, move...), size diff ]
=>  mime	node_id	req_t	sid	size	tstamp	type	user_id :: fsu
u1file_mime_unique_sid[mime	node_id	req_t	sid	size	tstamp	type	user_id]



-- drop table if exists u1
-- create table
drop table if exists u1file_size_mime;

create table u1file_size_mime(
  node_id bigint,
  min bigint,
  max bigint,
  edits bigint,
  mime string,
  type string,
  user_id bigint
) stored as parquet;

insert into u1file_size_mime
select
fsd.node_id,
fsd.min,
fsd.max,
fsd.edits,
fmu.mime,
fmu.type,
fmu.user_id
from u1file_mime_unique_sid fmu
inner join u1file_size_diff fsd
on fmu.node_id = fsd.node_id ;


show table stats u1file_size_mime;


select node_id, count(*) hit from u1file_size_mime group by node_id order by hit desc
>> split mime into multipart and none_multipart
  regexp_extract(mime, '.*?/(.*?)\'', 1 ) as none_multipart,
  regexp_extract(mime, '.*?\'(.*?)/.*?', 1) as multipart,

>>
drop table if exists u1file_size_multipart;
create table u1file_size_multipart
(
  node_id bigint,
  min bigint,
  max bigint,
  edits bigint,
  -- mime string,
  multipart string,
  none_multipart string,
  type string,
  user_id bigint
) stored as parquet;
insert into u1file_size_multipart
select node_id, min, max, edits,
  regexp_extract(mime, '.*?\'(.*?)/.*?', 1) as multipart,
  regexp_extract(mime, '.*?/(.*?)\'', 1 ) as none_multipart,
type, user_id
from u1file_size_mime;

show table stats u1file_size_multipart;

--




--
Extend the traces with additional information related to its node_id

drop table if exists u1trace_backup_size_multipart;

create table u1trace_backup_size_multipart(
  req_t string,
  size bigint,
  node_id bigint,
  min bigint,
  max bigint,
  edits bigint,
  multipart string,
  none_multipart string,
  type string,
  user_id bigint
  ) stored as parquet;
  insert into u1trace_backup_size_multipart
select t.req_t, t.size, fsm.* from u1trace_backup t inner join u1file_size_multipart fsm on fsm.node_id = t.node_id;

show table stats u1trace_backup_size_multipart;


-- download

drop table if exists u1trace_download_size_multipart;

create table u1trace_download_size_multipart(
  req_t string,
  size bigint,
  node_id bigint,
  min bigint,
  max bigint,
  edits bigint,
  multipart string,
  none_multipart string,
  type string,
  user_id bigint
  ) stored as parquet;
  insert into u1trace_download_size_multipart
select t.req_t, t.size, fsm.* from u1trace_download t inner join u1file_size_multipart fsm on fsm.node_id = t.node_id;

show table stats u1trace_download_size_multipart;

-- sync

drop table if exists u1trace_sync_size_multipart;

create table u1trace_sync_size_multipart(
  req_t string,
  size bigint,
  node_id bigint,
  min bigint,
  max bigint,
  edits bigint,
  multipart string,
  none_multipart string,
  type string,
  user_id bigint
  ) stored as parquet;
  insert into u1trace_sync_size_multipart
select t.req_t, t.size, fsm.* from u1trace_sync t inner join u1file_size_multipart fsm on fsm.node_id = t.node_id;

show table stats u1trace_sync_size_multipart;

-- hecho
[cdf de tipo de operacion]
select req_t, count(*) hit-- size, multipart
from u1trace_download_size_multipart
-- where size is null
group by req_t
order by hit


[cdf de ficheros mas editados]
-- ficheros mas editados por tipo
select multipart, count(*) hit
from u1trace_backup_size_multipart
group by multipart order by hit desc;


[cdf de ficheros mas editados por tipo y operacion]
select multipart, req_t, count(*) hit
from u1trace_backup_size_multipart
group by multipart, req_t order by hit des


[cdf de tamaño ficheros por extension(multipart)]
-- caso cuando es PUT & GET tiene size



-- caso de MOVE, UNLINK & MAKE nosize


alter table u1trace_download_size_multipart rename to u1trace_size_multipart_download;

alter table u1trace_sync_size_multipart rename to u1trace_size_multipart_sync;

alter table u1trace_backup_size_multipart rename to u1trace_size_multipart_backup;

-- rename
drop table if exists u1mime_considere;
create table u1mime_considered(
multipart string
)stored as parquet;
insert into u1mime_considered
select multipart
from u1trace_size_multipart_backup
where req_t = 'GetContentResponse'
group by multipart

--
chemical
audio
message
video
application
image
text
--
