db2 create database db2hadr
mkdir archivelog
db2 update db cfg for db2hadr using logarchmeth1 disk:/home/db2inst1/archivelog
db2 force applications all
db2 backup db db2hadr to /home/db2inst1/data 
db2 backup db db2hadr online to /home/db2inst1/data include logs| tee backup.log
backup_timestamp=$(cat backup.log | cut -d":" -f2 | sed 's/ //g')
echo ${backup_timestamp} > /home/db2inst1/data/backupid
backup_file=$(ls data|grep $backup_timestamp)
#rm -f /home/db2inst1/data/${backup_file}
#db2 backup db db2hadr online to /home/db2inst1/data include logs

#hadr1 configure
db2set DB2_HADR_ROS=ON
db2set DB2_STANDBY_ISO=UR
db2set DB2_HADR_SOSNDBUF=1024000
db2set DB2_HADR_SORCVBUF=1024000
db2 update db cfg for db2hadr using HADR_LOCAL_HOST hadr1
db2 update db cfg for db2hadr using HADR_LOCAL_SVC 60000
db2 update db cfg for db2hadr using HADR_REMOTE_HOST hadr2
db2 update db cfg for db2hadr using HADR_REMOTE_SVC 60000
db2 update db cfg for db2hadr using HADR_REMOTE_INST db2inst1
db2 update db cfg for db2hadr using HADR_TIMEOUT 120
db2 update db cfg for db2hadr using HADR_SYNCMODE NEARSYNC
db2 update db cfg for db2hadr using HADR_PEER_WINDOW 300
db2 update db cfg for db2hadr using LOGINDEXBUILD ON