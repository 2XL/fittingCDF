
-- seleccionar usuarios por perfil



-- synchronization


select user_id, updates
from (select *, put - putu as updates from xl_user_put_stats) as t
where updates >= 100 order by updates desc

		Gets those users that have performed atleast 100 updates
count(*):		29 213 users found

select count(*) from u1user_profile where profile = "sync";     -- 19096
