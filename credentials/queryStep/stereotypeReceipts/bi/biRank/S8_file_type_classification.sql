

-- STAGE 1


-- [cdn, cdn, cdn, cdn, cdn]

drop table if exists xl_file_type_cdn;

create table xl_file_type_cdn (
user_id bigint,
node_id bigint,
type string
) stored as parquet;

insert into xl_file_type_cdn(user_id, node_id, type)
select user_id, node_id, type
from    
(
select u.user_id, u.node_id, u.type
from xlp_profile_cdn p
inner join default.ubuntu_one u 
on (p.user_id = u.user_id)
where t = 'storage_done' and type != ''
) as t;

show table stats xl_file_type_cdn;


-- STAGE 2



-- download as csv




-- xl_type_file_cdn.csv


select isnull(fil.user_id, dir.user_id) user_id, isnull(dir.dir, 0) dir, isnull(fil.file, 0) file
from

(
select user_id, count(distinct node_id) file
from xl_file_type_cdn
where type='File'
group by user_id
order by file desc
) as fil

full outer join 

-- xl_type_dir_cdn.csv
(
select user_id, count(distinct node_id) dir
from xl_file_type_cdn
where type='Directory'
group by user_id
order by dir desc
) as dir

 on (dir.user_id = fil.user_id )


