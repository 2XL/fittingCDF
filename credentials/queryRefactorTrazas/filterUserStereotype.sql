

[USER_STEREOTYPE_PROFILE]
-- user_download
create table u1stereo_download like u1profile.u1user_type_download;
insert into u1stereo_download
select * from u1profile.u1user_type_download;
-- user_sync
create table u1stereo_sync like u1profile.u1user_type_sync;
insert into u1stereo_sync
select * from u1profile.u1user_type_sync;
-- user_backup
create table u1stereo_backup like u1profile.u1user_type_backup;
insert into u1stereo_backup
select * from u1profile.u1user_type_backup where user_id not in (select user_id from u1stereo_sync);
-- all users
create table u1stereo_all like u1stereo_backup;
insert into u1stereo_all
select * from u1stereo_backup;
insert into u1stereo_all
select * from u1stereo_download;
insert into u1stereo_all
select * from u1stereo_sync;
select count(*) from u1stereo_all -- 114033
                                  --  71929 -- backup
                                  --  23008 -- download
                                  --  19096 -- sync -- 6444 sync que no son backup

[CONSIDERED MIME TYPES]
create table u1mime_considered like u1profile.u1mime_considered;
insert into u1mime_considered
select * from u1profile.u1mime_considered;
0 application
1	image
2	text
3	chemical
4	audio
5	message
6	video


[TRACES BELONG THIS GROUP OF USERS]
-- select count(*) from u1profile.ubuntu_one_profiling_sid where user_id in (select * from u1stereo_all); -- 227038656
select count(*) from u1profile.ubuntu_one_profiling_sid                                                   -- 459344862
-- [TRACES WITH ALL THE USERS]
drop table if exists u1trace_all;
create table u1trace_all like u1profile.ubuntu_one_profiling_sid;
insert into u1trace_all
select * from u1profile.ubuntu_one_profiling_sid where user_id in (select * from u1stereo_all); -- 227038656
-- [FILES WHERE node_id->mime is DEFINED]
create table u1file_with_mime like u1profile.u1file_size_multipart;
insert into u1file_with_mime
select * from u1profile.u1file_size_multipart;
-- select node_id, count(*) hit from u1file_with_mime group by node_id order by hit desc; -- files are unique
-- select count(*) from u1file_with_mime; -- 71 612 847 -- unique files with mime defined
-- [TABLE with node_id's that has mime DEFINED]
create table u1file_nid_with_mime( node_id bigint) stored as parquet;
insert into u1file_nid_with_mime
select node_id from u1file_with_mime;
-- [CONSIDER THE TRACES WHERE MIME TYPE IS DEFINED]
create table u1trace_all_with_mime like u1trace_all;
insert into u1trace_all_with_mime
SELECT * FROM u1trace_all where node_id in (select * from u1file_nid_with_mime);
--
drop table if exists u1trace_all_size_multipart;
create table u1trace_all_size_multipart(
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
  insert into u1trace_all_size_multipart
select t.req_t, t.size, fsm.* from u1trace_all_with_mime t inner join u1file_with_mime fsm on fsm.node_id = t.node_id;
show table stats u1trace_all_size_multipart;
--
-- file TYPE [cdf de fichero por formato]
con la tabla u1file_with_mime

# multipart	        none_multipart	    hit
0	image	jpeg	                12 245 298
1	image	png	                  9708042
2	text	html	                4455410
3	application	x-httpd-php	    4189084
4	application	pdf	            3354467
5	text	plain	                2989341
6	application	javascript	2937699
7	application	java-vm	2707452
8	application	xml	2606380
9	image	gif	2417041
10	text	x-chdr	1771552
11	audio	mpeg	1534823
12	text	x-csrc	1459302
13	application	msword	1371917
14	text	x-java	1308872
15	text	x-python	1066991
16	application	x-ns-proxy-autoconfig	943659
17	text	css	844189
18	application	x-object	827448
19	text	x-c++src	734260
20	application	java-archive	658073

select multipart, count(*) hit
from u1file_with_mime
where multipart in (select * from  u1mime_considered)
group by multipart order by hit desc

select multipart, count(*) hit from u1stereo.u1file_with_mime where multipart in (select * from  u1stereo.u1mime_considered) group by multipart order by hit desc

#!/usr/bin/env bash
qq="select multipart, count(*) hit from u1stereo.u1file_with_mime where multipart in (select * from  u1stereo.u1mime_considered) group by multipart order by hit desc"
out="/home/lab144/chenglong/martes/cdf_file_type.csv"
impala-shell -B -o "$out" --output_delimiter=',' -q "$qq"


 	multipart	hit
0	image	26024888
1	application	25722320
2	text	16695481
3	audio	2370868
4	chemical	445983
5	video	248956
6	message	95169


-- file SIZE [cdf de fichero mas editados]
-- cdf_most_edited_type
create table cdf_most_edited_type (multipart string, hit bigint) stored as parquet;
insert into cdf_most_edited_type
select multipart, count(*) hit from
u1trace_all_size_multipart
where multipart in (select * from u1mime_considered)
group by multipart
order by hit desc;

 	multipart	hit
0	application	42124728
1	image	32968476
2	text	24112194
3	audio	5415416
4	video	4717531
5	chemical	503232
6	message	136886


-- target

-- saber los 5 extensiones mas extendidos para cada multipart
/*
select  *, rank() over(order by multipart, -hit) as rank from

(
select multipart, none_multipart, count(*) hit
from u1file_with_mime
where multipart in (select * from  u1mime_considered)
group by multipart, none_multipart order by hit desc
  ) as t
  order by rank
  */
  /*
 	multipart
0	application
1	image
2	text
3	chemical
4	audio
5	message
6	video
  */

  -- select * from u1mime_considered ;
  -- top 5 ranked

  -- create table u1file_top_5_none_multipart( multipart string, none_multipart string, hit bigint) stored as parquet;

  insert into u1file_top_5_none_multipart
  select multipart, none_multipart, count(*) hit
  from u1file_with_mime
  where multipart = 'video'
  group by multipart, none_multipart
  order by hit desc
  limit 5




--
create table u1file_top_30_mime like u1file_top_5_none_multipart;
insert into u1file_top_30_mime
select multipart, none_multipart, count(*) hit
  from u1file_with_mime
  group by multipart, none_multipart
  order by hit desc
  limit 30



[file size distribution]

-- hay 433666 ficheros donde el tamaño maximo es zero
--   71612847 total numero de ficheros



-- file_size by  multipart

create table cdf_file_size_application(min bigint, max bigint) stored as parquet;
insert into cdf_file_size_application
select  min, max from u1file_with_mime where multipart = 'application'; -- application filesize

create table cdf_file_size_image(min bigint, max bigint) stored as parquet;
insert into cdf_file_size_image
select  min, max from u1file_with_mime where multipart = 'image'; -- application filesize


create table cdf_file_size_text(min bigint, max bigint) stored as parquet;
insert into cdf_file_size_text
select  min, max from u1file_with_mime where multipart = 'text'; -- application filesize


create table cdf_file_size_chemical(min bigint, max bigint) stored as parquet;
insert into cdf_file_size_chemical
select  min, max from u1file_with_mime where multipart = 'chemical'; -- application filesize


create table cdf_file_size_audio(min bigint, max bigint) stored as parquet;
insert into cdf_file_size_audio
select  min, max from u1file_with_mime where multipart = 'audio'; -- application filesize


create table cdf_file_size_message(min bigint, max bigint) stored as parquet;
insert into cdf_file_size_message
select  min, max from u1file_with_mime where multipart = 'message'; -- application filesize


drop table if exists cdf_file_size_video;
create table cdf_file_size_video(min bigint, max bigint) stored as parquet;
insert into cdf_file_size_video
select  min, max from u1file_with_mime where multipart = 'video'; -- application filesize




/*
0	application
1	image
2	text
3	chemical
4	audio
5	message
6	video
*/



select count(*) from cdf_file_size_application; -- 25722320
select count(*) from cdf_file_size_audio;       -- 2370868
select count(*) from cdf_file_size_chemical;    -- 445983
select count(*) from cdf_file_size_image;       -- 26024888
select count(*) from cdf_file_size_message;     -- 95169
select count(*) from cdf_file_size_text;        -- 16695481


-- [CDF de ediciones(req_t) y tipo (mime) de fichero]
put cdf
get cdf
unlink cdf
make cdf
move cdf


create table cdf_file_type_request_make(multipart string, hit bigint) stored as parquet;
insert into cdf_file_type_request_make
select multipart, count(*) hit from u1trace_all_size_multipart
where req_t = 'MakeResponse'
and multipart in (select * from u1mime_considered)
group by multipart
order by hit desc;



create table cdf_file_type_request_unlink(multipart string, hit bigint) stored as parquet;
insert into cdf_file_type_request_unlink
select multipart, count(*) hit from u1trace_all_size_multipart
where req_t = 'Unlink'
and multipart in (select * from u1mime_considered)
group by multipart
order by hit desc;


create table cdf_file_type_request_move(multipart string, hit bigint) stored as parquet;
insert into cdf_file_type_request_move
select multipart, count(*) hit from u1trace_all_size_multipart
where req_t = 'MoveResponse'
and multipart in (select * from u1mime_considered)
group by multipart
order by hit desc;



create table cdf_file_type_request_put(multipart string, hit bigint) stored as parquet;
insert into cdf_file_type_request_put
select multipart, count(*) hit from u1trace_all_size_multipart
where req_t = 'PutContentResponse'
and multipart in (select * from u1mime_considered)
group by multipart
order by hit desc;


create table cdf_file_type_request_get(multipart string, hit bigint) stored as parquet;
insert into cdf_file_type_request_get
select multipart, count(*) hit from u1trace_all_size_multipart
where req_t = 'GetContentResponse'
and multipart in (select * from u1mime_considered)
group by multipart
order by hit desc;

-----

[cdf: de cada estereotipo sacar el % de ficheros de cada mime]


create table cdf_file_type_download like cdf_file_type;
insert into cdf_file_type_download
select multipart, count(*) hit from u1trace_all_size_multipart
where multipart in (select * from u1mime_considered)
and user_id in (select * from u1stereo_download)
group by multipart
order by hit desc;


create table cdf_file_type_sync like cdf_file_type;
insert into cdf_file_type_sync
select multipart, count(*) hit from u1trace_all_size_multipart
where multipart in (select * from u1mime_considered)
and user_id in (select * from u1stereo_sync)
group by multipart
order by hit desc;


create table cdf_file_type_backup like cdf_file_type;
insert into cdf_file_type_backup
select multipart, count(*) hit from u1trace_all_size_multipart
where multipart in (select * from u1mime_considered)
and user_id in (select * from u1stereo_backup)
group by multipart
order by hit desc;



















