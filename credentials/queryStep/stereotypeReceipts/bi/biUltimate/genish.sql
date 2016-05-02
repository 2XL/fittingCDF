



tstamp, user_id, req_t, node_id, type, size, ext



current 

x




 cdn i dels backup









select count(*) from xls_traces_cdn
19327356



select count(*) from xls_traces_backup
60642466
select count(*) from xlp_traces_backup
130092258


t, ext, size, tstamp, req_t, node_id, user_id



tstamp, user_id, req_t, node_id, type, size, ext


create table if not exists filtered_genis (
  ext string,
  size bigint,
  type string,
  tstamp timestamp,
  req_t string,
  node_id bigint,
  user_id bigint,
  user_type string
) stored as parquet;

insert into filter_req_activity_64389_pk
select * from activity_64389_pk where req_t="GetContentResponse" or req_t="MakeResponse" or req_t="MoveResponse" or req_t="PutContentResponse" or req_t="Unlink" ;
 


drop table filtered_geniss;
create table if not exists filtered_geniss (
  ext string,
  size bigint,
  type string,
  tstamp timestamp,
  req_t string,
  node_id bigint,
  user_id bigint,
  user_type string
) stored as parquet;



insert into filtered_geniss
 select *, 'cdn' as user_type from
 (select ext, size, type, tstamp, req_t, node_id, user_id
 from default.ubuntu_one where user_id in (select * from chenglong.xlp_profile_cdn) and t = 'storage_done') as t 
 where req_t="GetContentResponse" or req_t="MakeResponse" or req_t="MoveResponse" or req_t="PutContentResponse" or req_t="Unlink" ;




insert into filtered_geniss
 select *, 'backup' as user_type from
 (select ext, size, type, tstamp, req_t, node_id, user_id
 from default.ubuntu_one where user_id in (select * from chenglong.xlp_profile_backup) and t = 'storage_done') as t 
 where req_t="GetContentResponse" or req_t="MakeResponse" or req_t="MoveResponse" or req_t="PutContentResponse" or req_t="Unlink" ;


-----------

64389 -> 

-- select count(*) from filtered_genis --> 70452949

-- select * from activity_64448 -- > 304086

 
-- select count(*) from activity_64449 -- > 25616

-- select count(*) from (select *, floor(floor(unix_timestamp(tstamp)/3600)/6) idx from filtered_genis ) as t where idx = 64448 -- 281793

select count(*) from (select *, floor(floor(unix_timestamp(tstamp)/3600)/6) idx from filtered_genis ) as t where idx = 64449 -- 23864

-- 87467

