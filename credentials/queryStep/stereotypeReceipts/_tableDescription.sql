
:: > profile
=> user_id
u1user_type_backup    => usuarios de tipo backup    []
u1user_type_download  => usuarios de tipo download  []
u1user_type_sync      => usuarios de tipo sync      []


:: > trazas por profile de usuario
=> from_gen	current_gen	ext	hash	mime	node_id	req_t	shared_by	shared_to	size	tstamp	type	udfs	user_id
u1trace_backup_nn     => trazas de usuarios backup    []
u1trace_download_nn   => trazas de usuarios download  []
u1trace_sync_nn       => trazas de usuarios sync      []



:: > ficheros [UNIQUE] que pertenecien a un perfil especifico
=> 	none_multipart	multipart	node_id
u1file_profile_backup_mime      =>
u1file_profile_download_mime
u1file_profile_sync_mime
* node_id de todos los ficheros de ese grupo, con el mime de ese fichero
* node_id es unico en cada tabla

:: > contador de ficheros unicos por cada perfil
=> 	none_multipart	multipart	hit
u1file_mime_ops_hit_backup      =>
u1file_mime_ops_hit_download
u1file_mime_ops_hit_sync
* hit indica el numero de ficheros unicos de esa categoria none_multipart
image 20644021

:: > cdf de ficheros x mutipart [para cada grupo de usuario]
=> 	multipart	hit
u1file_type_prob_freq_backup    => sumatorio de ficheros agrupados por multipart
u1file_type_prob_freq_download
u1file_type_prob_freq_sync
* hit indica el numero de operaciones sobre ese multipart.
* select multipart, sum(hit) from u1file_mime_ops_hit_backup  group by multipart [de la tabla anterior]
* select * from u1file_type_prob_freq_backup order by hit desc [cdf de fichero por formato]



:: > cdf de ficheros mas editados por extension multipart [para cada categoria]
=>  multipart, hit_total, hit_put, hit_get, hit_remove, hit_make, hit_move

* paso cero => u1file_nid_uid_mime_size

>> 	node_id	min	max	edits	multipart	none_multipart	type	user_id
select * from u1file_size_multipart -- todos los ficheros unicos con sus medidas minimas y maximas

* hacer una tabla vacia con todos los multiparts
* add column a la tabla por cada multipart group by COUNT

-- antes de hacer esto hay que rellenar los campos de la tabla u1trace_XXXX
-- hay que rellenar los mime y los size para generar una tabla unica
-- con todos los campos o detalles rellenos.

* tengo file per SIZE <= falta analitzar per cada tipus de operació
* tengo file per extension <=


=> 	node_id	max	min	edits	diff
u1file_size_diff [node_id, max_size, min_size, operations(can  be make, move...), size diff ]
=>  mime	node_id	req_t	sid	size	tstamp	type	user_id
u1file_mime_unique_sid[mime	node_id	req_t	sid	size	tstamp	type	user_id]
-- select count(*) from u1file_mime_unique_sid --  95716028
-- select node_id, count(*) hit from u1file_mime_unique_sid group by node_id order by hit desc -- hit are unique






:: >
u1file_mime         => traces where the field mime is defined [ alter table u1file_mime rename to u1trace_with_mime;
u1file_mime_unique  => collection with all node_id where field mime is not undefined


