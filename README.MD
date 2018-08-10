## DB2 HADR docker compose guide

```
#  file docker-entrypoint.sh Dockerfile                     are used for image db210506
#  file db2hadr1.sh db2hadr2.sh hadr1_init.sh hadr2_init.sh are used for config db2 hadr container
#  file docker-compose.yml                                  are used for docker-compose 
#

Note:

about Dockerfile: prepare the db2 image , this eample is db2 10.5.0.6 ESE ,it can be trail for 90 days.

ARG DB2EXPRESSC_URL=http://****/v10.5.0.6/v10.5fp6_linuxx64_server_t.tar.gz
ARG DB2EXPRESSC_SHA256=911301ee155c5c0edf0af15074b2f67a2f54a3f8c866b156aca0f9b6fbd93be8

# sha256sum v10.5fp6_linuxx64_server_t.tar.gz
# 911301ee155c5c0edf0af15074b2f67a2f54a3f8c866b156aca0f9b6fbd93be8  v10.5fp6_linuxx64_server_t.tar.gz

```

## 1创建7个文件 ，可以用git拉下来

```
    docker-entrypoint.sh Dockerfile db2hadr1.sh db2hadr2.sh hadr1_init.sh hadr2_init.sh docker-compose.yml
    #cd /tmp/data
    #git clone https://github.com/JasonYLong/docker-compose-db2-hadr.git
```

## 2.创建自定义db2 images

```
    #docker build -t db210506 .
```

## 3.启动容器

```
    #docker-compose up
```

## 删除容器

```
    #docker-compose down
    #rm -f /tmp/data/*.001
    #rm -f /tmp/data/*.log
```

## hadr 切换(from primary to standby)

```
    #docker exec -it hadr2 bash
    #db2 takeover hadr on db db2hadr
    #db2pd -d db2hadr -hadr
```

## 使用已有镜像，搭建HADR 

```
   1.创建hadr初始化脚本
   #mkdir /tmp/data
   #cd /tmp/data 
   创建4个脚本  db2hadr1.sh db2hadr2.sh hadr1_init.sh hadr2_init.sh
   #chmod 777 *.sh

   2.创建网络my_net
   # docker network create --driver bridge --subnet 172.22.16.0/24 --gateway 172.22.16.1 my_net
   # brctl show
   # docker inspect my_net

   3.初始化脚本----hadr初始化，只用执行这个脚本，
   
   #docker run -d --network=my_net -p 50000:50000 -h hadr1 --name=hadr1 -e DB2INST1_PASSWORD=db2inst1 -e LICENSE=accept -v /tmp/data:/home/db2inst1/data ibmcom/db2express-c:latest db2start
   #docker run -d --network=my_net -p 50001:50000 -h hadr2 --name=hadr2 -e DB2INST1_PASSWORD=db2inst1 -e LICENSE=accept -v /tmp/data:/home/db2inst1/data ibmcom/db2express-c:latest db2start
   #docker exec -it hadr1 su - db2inst1 -c '/home/db2inst1/data/db2hadr1.sh'
   #docker exec -it hadr2 su - db2inst1 -c '/home/db2inst1/data/db2hadr2.sh'
   #docker exec -it hadr2 su - db2inst1 -c '/home/db2inst1/data/hadr2_init.sh'
   #docker exec -it hadr1 su - db2inst1 -c '/home/db2inst1/data/hadr1_init.sh'
```
