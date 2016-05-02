

drop table if exists xl_user_vol_sync;

-- step 1

-- sync, sync, sync, sync, sync

create table xl_user_vol_sync (
user_id bigint,
vol_id bigint
) stored as parquet;


insert into xl_user_vol_sync( user_id, vol_id )

select u.user_id, vol_id 
from xlp_profile_sync p
inner join default.ubuntu_one u 
on (p.user_id = u.user_id)
where vol_id is not null;


-- step 2

select user_id, count(*) hit from 
(select user_id, vol_id from xl_user_vol_sync
group by user_id, vol_id) as t
group by user_id
order by hit desc

-- save csv

