

-- contar el numero de archivos que hay
-- luego dividir los campos por ese valor..
select sum(hit) total_files from cdf_file_type_backup; --  81791722
select multipart, hit/81791722 dist from cdf_file_type_backup order by dist desc;


select sum(hit) total_files from cdf_file_type_sync; --  25222300
select multipart, hit/25222300 dist from cdf_file_type_sync order by dist desc;


select sum(hit) total_files from cdf_file_type_download; --  1138977
select multipart, hit/1138977 dist from cdf_file_type_download order by dist desc;


-- :: by request type


select sum(hit) total_files from cdf_file_type; --  71603665
select multipart, hit/81791722 dist from cdf_file_type order by dist desc;

select sum(hit) total_files from cdf_file_type_request_get; --  2936482
select multipart, hit/81791722 dist from cdf_file_type_request_get order by dist desc;

select sum(hit) total_files from cdf_file_type_request_put; --  58594908
select multipart, hit/81791722 dist from cdf_file_type_request_put order by dist desc;

select sum(hit) total_files from cdf_file_type_request_unlink; --  8182679
select multipart, hit/81791722 dist from cdf_file_type_request_unlink order by dist desc;

select sum(hit) total_files from cdf_file_type_request_make; --  37630069
select multipart, hit/81791722 dist from cdf_file_type_request_make order by dist desc;

select sum(hit) total_files from cdf_file_type_request_move; --  2634325
select multipart, hit/81791722 dist from cdf_file_type_request_move order by dist desc;



--

cdf file none_multipart by multipart

/*

select multipart, sum(hit) total
from u1file_top_5_none_multipart
group by multipart

 	multipart	total
0	image	25399871
1	video	199400
2	text	11984477
3	audio	2249959
4	chemical	372627
5	application	15795082
6	message	95169
*/


select none_multipart, sum(hit)/25399871 dist
from u1file_top_5_none_multipart
where multipart = "image"
group by none_multipart
order by dist desc;


select none_multipart, sum(hit)/199400 dist
from u1file_top_5_none_multipart
where multipart = "video"
group by none_multipart
order by dist desc;

select none_multipart, sum(hit)/11984477 dist
from u1file_top_5_none_multipart
where multipart = "text"
group by none_multipart
order by dist desc;


select none_multipart, sum(hit)/2249959 dist
from u1file_top_5_none_multipart
where multipart = "audio"
group by none_multipart
order by dist desc;


select none_multipart, sum(hit)/372627 dist
from u1file_top_5_none_multipart
where multipart = "chemical"
group by none_multipart
order by dist desc;


select none_multipart, sum(hit)/15795082 dist
from u1file_top_5_none_multipart
where multipart = "application"
group by none_multipart
order by dist desc;

select none_multipart, sum(hit)/95169 dist
from u1file_top_5_none_multipart
where multipart = "message"
group by none_multipart
order by dist desc;

