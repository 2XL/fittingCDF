
## fitting array into dist+{params}

1. extraer los interarrivals de los clientes de perfil

juntar todos los interarrivals en una misma tabla
user_id, op1, op2, elapsed


```sql
drop table if exists operation_chain;
create table operation_chain like u1_tiny_backup_raw;
insert into operation_chain
select * from u1_tiny_backup_raw;
insert into operation_chain
select * from u1_tiny_cdn_raw;
insert into operation_chain
select * from u1_tiny_idle_raw;
insert into operation_chain
select * from u1_tiny_regular_raw;
insert into operation_chain
select * from u1_tiny_sync_raw;
show table stats operation_chain;
```

extraer tres tablas de la tabla conjunta, uno por cada perfil

    1. backup
    2. sync
    3. download

```sql
create table operation_chain_sync like chenglong.operation_chain;
insert into operation_chain_sync
select * from chenglong.operation_chain where user_id in (select * from u1stereo_sync)

create table operation_chain_backup like chenglong.operation_chain;
insert into operation_chain_backup
select * from chenglong.operation_chain where user_id in (select * from u1stereo_backup)

create table operation_chain_download like chenglong.operation_chain;
insert into operation_chain_download
select * from chenglong.operation_chain where user_id in (select * from u1stereo_download)
```

# generar csv de cada perfil

```bash

# u1stereo_sync
# u1stereo_backup
# u1stereo_download


declare -a profile=("download" "sync" "backup")
declare -a op1=("MakeResponse" "Unlink" "MoveResponse" "GetContentResponse" "PutContentResponse")
declare -a op2=("MakeResponse" "Unlink" "MoveResponse" "GetContentResponse" "PutContentResponse")
## now loop through the above array
for p in "${profile[@]}"
do
        for i in "${op1[@]}"
        do
                for j in "${op2[@]}"
                do
                echo "$p", "$j","$i"

                query="select user_id, elapsed from u1stereo.operation_chain_"$p" where op1 = '$j' and op2 = '$i'"
                echo $query

                output="/home/lab144/chenglong/stereo/"$p"_"$j"_"$i".csv"
                echo $output
                impala-shell -B -o $output --output_delimiter=',' -q "$query"

                # or do whatever with individual element of the array
                done
           # or do whatever with individual element of the array
        done
done


# descargar los csv  con scp
# scp your_username@remotehost.edu:foobar.txt /some/local/directory


```



2. generar tabla.dat, para cada perfile
    * sid, time

        hacer un merge de todas las tables

3. arrancar matlab i calcular allfitdist.m
    * guardar los variables para cada stereotype + op, op

4. meter parsear los variables generados en el utils de modulo de datagenerator
    * generar los variables con el formato que hay en el modulo workload_generator.utils

5. actualizar las recetas.
    * finish cooking recipe.




sample:
```csv

operation_chain,MoveResponse,MoveResponse,1401,invgauss,{'shape':1363.32646109922,'scale':0.101918365352736}
operation_chain,MoveResponse,PutContentResponse,719,genextreme,{'shape':-2.11992852538215,'scale':3.2980052810641,'loc':1.54615519456346}
operation_chain,MoveResponse,Unlink,398,genpareto,{'shape':3.02809764917398,'scale':0.0664626786932026,'threshold':0.0279999999328978}
operation_chain,PutContentResponse,MoveResponse,789,genextreme,{'shape':-3.45248397723402,'scale':24.7987682442144,'loc':7.19504059331674}
operation_chain,PutContentResponse,PutContentResponse,56203,genextreme,{'shape':-1.87110387302981,'scale':0.38096890778117,'loc':0.199634595057584}
operation_chain,PutContentResponse,Unlink,978,genpareto,{'shape':5.59532304512292,'scale':0.430467922602313,'threshold':0.00499999988823778}
operation_chain,Unlink,MoveResponse,318,genpareto,{'shape':4.05974572112893,'scale':0.230971524365217,'threshold':0.0200000000185978}
operation_chain,Unlink,PutContentResponse,1053,genpareto,{'shape':3.13573091706067,'scale':0.746839394368102,'threshold':0.00100000016390778}
operation_chain,Unlink,Unlink,18057,genpareto,{'shape':0.949044501927819,'scale':0.0508355787457194,'threshold':0.0249999999068978}
```