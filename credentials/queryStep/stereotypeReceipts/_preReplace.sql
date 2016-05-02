


drop table if exists u1file_type_prob_freq_download;
create table u1file_type_prob_freq_download(multipart string, hit bigint) stored as parquet;
insert into u1file_type_prob_freq_download
select multipart, sum(hit) hit
from u1file_mime_hit_download
group by multipart


-- select count(*) from u1file_mime_unique; -- 118929449
                                            --  56711894

select * from u1file_mime_unique as fmu inner join u1user_type_backup as utb on fmu.user_id = utb.user_id;


-- mime_hit_XXX
-- mustra el numero de archivos encontrados que hace matching de cierto mime



-- mime_