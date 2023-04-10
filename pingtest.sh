#!/bin/bash

# test of task by crontab
cat <<EOF >> /etc/crontab
*/3 * * * * root /usr/bin/bash -c "ping -c 3 8.8.8.8 >/dev/null || ping -c 3 1.1.1.1 >/dev/null; if [ $? != 0 ]; then echo 'ping not worked' `date` >> $HOME/ping.log; else echo 'ping OK' `date` >> $HOME/ping.log; fi"
