

create table u1file_top_50_mime(multipart string, none_multipart string, hit bigint) stored as parquet;
insert into u1file_top_50_mime
select multipart, none_multipart, count(*) hit from u1file_with_mime
group by multipart, none_multipart order by hit desc
limit 50







