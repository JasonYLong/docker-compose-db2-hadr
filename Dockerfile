FROM centos:7
MAINTAINER Jason Yuan <lyuan@cn.ibm.com>
RUN groupadd db2iadm1 && useradd -G db2iadm1 db2inst1
RUN yum install -y \
    vi \
    sudo \
    passwd \
    pam \
    pam.i686 \
    ncurses-libs.i686 \
    file \
    libaio \
    libstdc++-devel.i686 \
    numactl-libs \
    which \
    && yum clean all

ENV DB2EXPRESSC_DATADIR /home/db2inst1/data

ARG DB2EXPRESSC_URL=http://****/ftp/MIDDLEWARE/DB2/v10.5.0.6/v10.5fp6_linuxx64_server_t.tar.gz
ARG DB2EXPRESSC_SHA256=911301ee155c5c0edf0af15074b2f67a2f54a3f8c866b156aca0f9b6fbd93be8

RUN curl -fSLo /tmp/v10.5fp6_linuxx64_server_t.tar.gz $DB2EXPRESSC_URL \
    && echo "$DB2EXPRESSC_SHA256 /tmp/v10.5fp6_linuxx64_server_t.tar.gz" | sha256sum -c - \
    && cd /tmp && tar xf v10.5fp6_linuxx64_server_t.tar.gz \
    && su - db2inst1 -c "/tmp/server_t/db2_install -b /home/db2inst1/sqllib -p SERVER" \
    && echo '. /home/db2inst1/sqllib/db2profile' >> /home/db2inst1/.bash_profile \
    && rm -rf /tmp/v10.5fp6* && rm -rf /tmp/server_t* \
    && sed -ri  's/(ENABLE_OS_AUTHENTICATION=).*/\1YES/g' /home/db2inst1/sqllib/instance/db2rfe.cfg \
    && sed -ri  's/(RESERVE_REMOTE_CONNECTION=).*/\1YES/g' /home/db2inst1/sqllib/instance/db2rfe.cfg \
    && sed -ri 's/^\*(SVCENAME=db2c_db2inst1)/\1/g' /home/db2inst1/sqllib/instance/db2rfe.cfg \
    && sed -ri 's/^\*(SVCEPORT)=48000/\1=50000/g' /home/db2inst1/sqllib/instance/db2rfe.cfg \
    && mkdir $DB2EXPRESSC_DATADIR && chown db2inst1.db2iadm1 $DB2EXPRESSC_DATADIR

#RUN su - db2inst1 -c "db2start && db2set DB2COMM=TCPIP && db2 UPDATE DBM CFG USING DFTDBPATH $DB2EXPRESSC_DATADIR IMMEDIATE && db2 create database db2inst1" \

RUN su - db2inst1 -c "db2start && db2set DB2COMM=TCPIP" \
    && su - db2inst1 -c "db2stop force" \
    && cd /home/db2inst1/sqllib/instance \
    && ./db2rfe -f ./db2rfe.cfg

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

VOLUME $DB2EXPRESSC_DATADIR

EXPOSE 50000
