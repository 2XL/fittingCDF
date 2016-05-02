select req_t, req_t_next, avg(UNIX_TIMESTAMP(tstamp_next) - UNIX_TIMESTAMP(tstamp)) seconds from xl_ops_idle_pair
group by req_t, req_t_next