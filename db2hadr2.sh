backup_path=/home/db2inst1/data
backup_tmp=$(ls /home/db2inst1/data/*.001)
backup_file=${backup_tmp##*/}
backup_timestamp=$(echo $backup_file|cut -d "." -f5)
#find $backup_path -cmin +10 -exec rm -f {} \;
#avoid error SQL2043N  Unable to start a child process or thread.
db2 create database db2hadr
mkdir archivelog
# restore database
db2 restore db db2hadr from $backup_path taken at $backup_timestamp without prompting

#hadr1 configure
db2set DB2_HADR_ROS=ON
db2set DB2_STANDBY_ISO=UR
db2set DB2_HADR_SOSNDBUF=1024000
db2set DB2_HADR_SORCVBUF=1024000
db2 update db cfg for db2hadr using HADR_LOCAL_HOST hadr2
db2 update db cfg for db2hadr using HADR_LOCAL_SVC 60000
db2 update db cfg for db2hadr using HADR_REMOTE_HOST hadr1
db2 update db cfg for db2hadr using HADR_REMOTE_SVC 60000
db2 update db cfg for db2hadr using HADR_REMOTE_INST db2inst1
db2 update db cfg for db2hadr using HADR_TIMEOUT 120
db2 update db cfg for db2hadr using HADR_SYNCMODE NEARSYNC
db2 update db cfg for db2hadr using HADR_PEER_WINDOW 300
db2 update db cfg for db2hadr using LOGINDEXBUILD ON