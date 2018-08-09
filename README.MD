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
