



-- [sync, backup, regular, idle, cdn]

// select traces and add relative ranks for 
// idx,  -- for pairing
// rel idx, -- for user_id, req_t, node_id; over id
// rel bool, -- for 


drop table if exists xl_ops_XXXX;

create table xl_ops_XXXX  
( 
 id bigint,-- int not null auto_increment,
 user_id bigint,
 req_t string,
 tstamp timestamp, 
 node_id bigint
) stored as parquet;


insert into xl_ops_XXXX (id, user_id, req_t,tstamp, node_id) 
select row_number() over(order by tstamp asc)
as id ,user_id, req_t, tstamp, node_id
from xlp_traces_XXXX -- xl_traces_XXXX_sd
where t = 'storage_done' and
req_t in ('PutContentResponse', 'GetContentResponse', 'MoveResponse', 'Unlink');

-- select count(*) from xl_ops_XXXX

compute stats xl_ops_XXXX;
