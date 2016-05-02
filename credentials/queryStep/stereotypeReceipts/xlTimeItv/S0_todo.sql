

-- 

-- 5 profiles


-- 3 types of sessions



-- TODO

0th

user_id, tstart, tend, count(ops) where req_t = 'a,b,c,d,e'



1st  

# retrieve all the sessions by user-profile

user_id, t_start, t_finish, elapsed, count() ops



2nd

# online -> check if count() > 0

# sessions, partition by user, tstart order by tstart

tstart  	tend		tstart_next
	online								-> elapsed [tstart -> tend]
 				offline					-> elapsed [tend -> tstart_next]

count(ops)

# offline -> 

# repeat

# enllaçar totes les sessions

// les taules online, offline i actius s+obtenen de la taula temporal anterior



3rd

generar les taules 
	online
	offline
	actius
		(INI_TIMESLOT	tstamp    , SESSION_LENGTH   ms, bigint)
		[T_INI_SESS - T_INI_TRAZA], [T_END_SESSION - T_INI_SESS]



generar les tauls amb escales convertides...


4th


comulative a,b,c and retrieve sum(%a,%b,%c) = 1

select, sum, analytic operators






