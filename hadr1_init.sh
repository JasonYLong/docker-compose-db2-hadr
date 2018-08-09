db2stop force
db2start
db2 DEACTIVATE DATABASE db2hadr
db2 start hadr on database db2hadr as primary
db2pd -d db2hadr -hadr