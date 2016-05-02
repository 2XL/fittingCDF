
-- seleccionar usuarios por perfil



-- Profile Download / Content Distribution

select count(user_id)
from (select *, size_put/size_get ratio from xl_user_ops_size) t
where ratio >= 1000
-- and user_id in(select user_id from xl_user_id_no_si)

select count(*) from u1user_profile where profile = "download"; -- 23008
