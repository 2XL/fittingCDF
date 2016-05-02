
-- seleccionar usuarios por perfil



-- Backup
select user_id
from (select *, size_get/size_put ratio from xl_user_ops_size) t
where ratio >= 1000
-- and user_id in(select user_id from xl_user_id_no_sib)




select count(*) from u1user_profile where profile = "backup";   -- 84581



Get those users that have 1000 times more download than upload
	count(*): 		25 747 users found
	count(**): 		24 884 users found

