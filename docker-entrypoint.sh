#!/bin/bash
#
#   Initialize DB2 instance in a Docker container
#
# # Authors:
#   Jason Yuan <lyuan@cn.ibm.com>
#   
#

pid=0

function log_info {
 echo -e $(date '+%Y-%m-%d %T')"\e[1;32m $@\e[0m"
}
function log_error {
 echo -e >&2 $(date +"%Y-%m-%d %T")"\e[1;31m $@\e[0m"
}

function stop_db2 {
  log_info "stopping database engine"
  su - db2inst1 -c "db2stop force"
}

function start_db2 {
  log_info "starting database engine"
  su - db2inst1 -c "db2start"
}

function restart_db2 {
  # if you just need to restart db2 and not to kill this container
  # use docker kill -s USR1 <container name>
  kill ${spid}
  log_info "Asked for instance restart doing it..."
  stop_db2
  start_db2
  log_info "database instance restarted on request"
}

function terminate_db2 {
  kill ${spid}
  stop_db2
  if [ $pid -ne 0 ]; then
    kill -SIGTERM "$pid"
    wait "$pid"
  fi
  log_info "database engine stopped"
  exit 0 # finally exit main handler script
}

trap "terminate_db2"  SIGTERM
trap "restart_db2"   SIGUSR1

if [ ! -f ~/db2inst1_pw_set ]; then
  if [ -z "$DB2INST1_PASSWORD" ]; then
    log_error "error: DB2INST1_PASSWORD not set"
    log_error "Did you forget to add -e DB2INST1_PASSWORD=... ?"
    exit 1
  else
    log_info "Setting db2inst1 user password..."
    (echo "$DB2INST1_PASSWORD"; echo "$DB2INST1_PASSWORD") | passwd db2inst1 > /dev/null  2>&1
    if [ $? != 0 ];then
      log_error "Changing password for db2inst1 failed"
      exit 1
    fi
    touch ~/db2inst1_pw_set
  fi
fi

#if [ ! -f ~/db2_license_accepted ];then
#  if [ -z "$LICENSE" ];then
#     log_error "error: LICENSE not set"
#     log_error "Did you forget to add '-e LICENSE=accept' ?"
#     exit 1
#  fi

#  if [ "${LICENSE}" != "accept" ];then
#     log_error "error: LICENSE not set to 'accept'"
#     log_error "Please set '-e LICENSE=accept' to accept License before use the DB2 software contained in this image."
#     exit 1#
#  fi
#  touch ~/db2_license_accepted
#fi

#setting db2nodes.cfg
if [ -z "$HOSTNAME" ];then
   log_error "db2nodes.cfg are not right. It should be changed."
   exit 1
else
   log_info "setting db2nodes.cfg"
   su - db2inst1 -c "echo '0 ${HOSTNAME} 0'>/home/db2inst1/sqllib/db2nodes.cfg"
fi   

# automatic to create sample database
#if [ -f /home/db2inst1/sqllib/install/db2ls ];then
#   su - db2inst1 -c "/home/db2inst1/sqllib/bin/db2sampl"
#fi

# 
# the order about hadr configuration
# 1. hadr1: /home/db2inst1/data/db2hadr1.sh       backup db and configure hadr
#           touch /home/db2inst1/data/hadr1.log

# 2. hadr2: /home/db2inst1/data/db2hadr2.sh       restore db and configure hadr
#           /home/db2inst1/data/hadr2_init.sh
#           touch /home/db2inst1/data/hadr2.log   restart instance and activate hadr

# 3.hadr1: /home/db2inst1/data/hadr1_init.sh      restart instance and activate hadr

if [[ $1 == "db2start" ]]; then
  log_info "Initializing container"
  start_db2
  log_info "Database db2diag log following"
  tail -f ~db2inst1/sqllib/db2dump/db2diag.log &
  
  while true
  do
    if [[ $HOSTNAME == 'hadr1' ]];then
      if [ ! -f /home/db2inst1/data/hadr1.log ];then
        su - db2inst1 -c '/home/db2inst1/data/db2hadr1.sh'
        su - db2inst1 -c 'touch /home/db2inst1/data/hadr1.log'
      fi
      if [ -f /home/db2inst1/data/hadr2.log ];then
        su - db2inst1 -c '/home/db2inst1/data/hadr1_init.sh'
        echo "hadr1 configure successfully!"
        break
      fi
    fi

    if [[ $HOSTNAME == 'hadr2' ]];then
      if [ -f /home/db2inst1/data/hadr1.log ];then
        su - db2inst1 -c '/home/db2inst1/data/db2hadr2.sh'
        su - db2inst1 -c '/home/db2inst1/data/hadr2_init.sh'
        su - db2inst1 -c 'touch /home/db2inst1/data/hadr2.log'
        echo "hadr2 configure successfully!"
        break
      fi
    fi
  done

  export pid=${!}
  while true
  do
    sleep 10000 &
    export spid=${!}
    wait $spid
  done
else
  exit 0
fi