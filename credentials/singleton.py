#!/usr/bin/env python
import os
import signal
import time





if __name__ == '__main__':
    # use file look

    if os.path.exists('monitor_rmq.pid'):

        # read the pid
        with open('monitor_rmq.pid', 'r') as f:
            first_line = f.readline()
            print first_line

        last_pid = first_line
        print "kill_last_pid: {}".format(last_pid)
        print last_pid
        try:
            # kill last pid
            os.kill(int(last_pid), signal.SIGTERM)  # kill previous if exists
        except Exception as e:
            print e.message
            print "warning not valid pid"

    # update/store current pid
    with open('monitor_rmq.pid', 'w') as f:
        f.write(str(os.getpid()))

        isEnd = 100


    while isEnd > 0:
        isEnd = isEnd - 1
        time.sleep(1)
        print isEnd
        # sys.exit(0)