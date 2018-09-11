#!/usr/bin/env groovy
pipeline{
    agent any
    stages{
        stage('Initial') {
            steps{
                git url: 'https://github.com/JasonYLong/docker-compose-db2-hadr.git'
                sh 'chmod 777 *.sh'
                sh 'chmod -R 777 ${WORKSPACE}'
                //sh 'ls;pwd'
                }
        }
        stage('create network'){
            steps{
               echo "create network"
               sh 'docker network create --driver bridge --subnet 172.22.16.0/24 --gateway 172.22.16.1 my_net || true'
               
            }
        }
        stage('create container'){
            steps{
                echo "create container hadr1 & hadr2"
                sh 'docker rm hadr1 hadr2 -f || true'
                sh 'docker run -d --network=my_net -p 50000:50000 -h hadr1 --name=hadr1 -e DB2INST1_PASSWORD=db2inst1 -e LICENSE=accept -v ${WORKSPACE}:/home/db2inst1/data ibmcom/db2express-c:latest db2start'
                sh 'docker run -d --network=my_net -p 50001:50000 -h hadr2 --name=hadr2 -e DB2INST1_PASSWORD=db2inst1 -e LICENSE=accept -v ${WORKSPACE}:/home/db2inst1/data ibmcom/db2express-c:latest db2start'
            }
        }
        stage('config HADR'){
            steps{
                echo "config HADR"
                sh 'docker exec -i hadr1 su - db2inst1 -c \'/home/db2inst1/data/db2hadr1.sh\''
                sh 'docker exec -i hadr2 su - db2inst1 -c \'/home/db2inst1/data/db2hadr2.sh\''
            }
        }
        stage('Active HADR'){
            steps{
                echo "Active HADR"
                sh 'docker exec -i hadr2 su - db2inst1 -c \'/home/db2inst1/data/hadr2_init.sh\''
                sh 'docker exec -i hadr1 su - db2inst1 -c \'/home/db2inst1/data/hadr1_init.sh\''
            }
        }
    }
}
