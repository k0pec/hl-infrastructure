######## Percona XtraDB Cluster установка #####################################################
# gcomm://10.0.26.201,10.0.26.202,10.0.26.203

-- пароль Otus321$
-- сконфигурируем кластер
sudo service mysql stop
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf


# PXC1
-- зададим ip всех узлов кластера и имя ноды
wsrep_cluster_address=gcomm://10.0.26.201,10.0.26.202,10.0.26.203
wsrep_node_name=pxc1

-- бутстрапим 1 ноду
-- https://www.percona.com/doc/percona-xtradb-cluster/8.0/bootstrap.html#bootstrap
sudo systemctl start mysql@bootstrap.service

nano ~/.my.cnf
[client]
password="Otus321$"

mysql
> show status like 'wsrep%';

-- on pxc1
mkdir -p /vagrant/ssl
cp /var/lib/mysql/{server-key,server-cert,ca}.pem /vagrant/ssl
chown -R vagrant:vagrant /vagrant/ssl

-- on pxc2
cp -r /vagrant/ssl/ /var/lib/mysql/
chown -R mysql:mysql /var/lib/mysql

-- on pxc3
cp -r /vagrant/ssl/ /var/lib/mysql/
chown -R mysql:mysql /var/lib/mysql


-- добавим другие ноды
-- https://www.percona.com/doc/percona-xtradb-cluster/8.0/add-node.html#add-node
-- on pxc2
sudo service mysql stop
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf

wsrep_cluster_name=pxc-cluster
wsrep_cluster_address=gcomm://10.0.26.201,10.0.26.202,10.0.26.203
wsrep_node_name=pxc2
sudo systemctl start mysql

-- on pxc3
sudo service mysql stop
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf

wsrep_cluster_address=gcomm://10.0.26.201,10.0.26.202,10.0.26.203
wsrep_node_name=pxc3


sudo systemctl start mysql

> show status like 'wsrep%';

# Статус в файле
cat /var/lib/mysql/grastate.dat
# Можно найти самый свежую ноду по позиции (seqno:)
# и safe_to_bootstrap: 1 говорит, что можно запусать с него кластер

###################################### Проверяем ############################################################

-- проверим, что все работает
create database otus;
use otus;
create table t (i int);
-- having an error
insert into t values (10), (20); 

-- почему ошибка?


CREATE TABLE accounts (
    id SERIAL,
    balance DECIMAL
);
insert into accounts(balance) values ('10.0'), ('20.0'); 
-- обратим внимание на id
select * from accounts; 

-- on pxc2 pxc3
mysql -p
use otus;
select * from accounts;
insert into accounts(balance) values ('10.0'), ('20.0'); 
select * from accounts;

-- если упали все ноды
2020-08-25T13:30:40.725502Z 0 [Note] [MY-000000] [WSREP] Starting replication
2020-08-25T13:30:40.725565Z 0 [Note] [MY-000000] [Galera] Connecting with bootstrap option: 1
2020-08-25T13:30:40.725640Z 0 [Note] [MY-000000] [Galera] Setting GCS initial position to a5066e8e-e5e5-11ea-942d-8a1ba08de78c:10
2020-08-25T13:30:40.725765Z 0 [ERROR] [MY-000000] [Galera] It may not be safe to bootstrap the cluster
from this node. 
!!! It was not the last one to leave the cluster !!!
and may not contain all the updates. 
To force cluster bootstrap with this node, edit the grastate.dat file manually and set safe_to_bootstrap to 1 .

-- настройки
show variables like '%wsrep%'\G
-- wsrep_provider_options

##################################### ProxySQL ################################################################

########### Установка ProxySQL

-- поставим proxySQL для лоад балансинга
-- https://www.percona.com/doc/percona-xtradb-cluster/8.0/howtos/proxysql.html#load-balancing-with-proxysql

sudo apt install percona-xtradb-cluster-client -y
sudo apt install proxysql2 -y

########### Настройка ProxySQL

-- заходим в собственную оболочку ProxySQL
mysql -u admin -padmin -h 127.0.0.1 -P 6032
> SHOW DATABASES;
> SHOW TABLES;


-- Adding cluster nodes to ProxySQL
INSERT INTO mysql_servers(hostgroup_id, hostname, port) VALUES (1,'10.0.26.201',3306);
INSERT INTO mysql_servers(hostgroup_id, hostname, port) VALUES (1,'10.0.26.202',3306);
INSERT INTO mysql_servers(hostgroup_id, hostname, port) VALUES (1,'10.0.26.203',3306);
SELECT * FROM mysql_servers;

-- как думаете заработает после этого?)

-- Note
ProxySQL has 3 areas where the configuration can reside:
    MEMORY (your current working place)
    RUNTIME (the production settings)
    DISK (durable configuration, saved inside an SQLITE database)
When you change a parameter, you change it in MEMORY area. That is done by design to allow you to test the changes before pushing to production (RUNTIME), or save them to disk.

-- https://github.com/sysown/proxysql/blob/master/doc/admin_tables.md
-- https://github.com/sysown/proxysql/blob/master/doc/global_variables.md
-- https://github.com/sysown/proxysql/blob/master/doc/configuration_howto.md

-- посмотрим статус мониторинга
SELECT * FROM monitor.mysql_server_connect_log ORDER BY time_start_us DESC LIMIT 6;
-- !!! иначе несмотря на наличие серверов нчиего работать не будет
LOAD MYSQL SERVERS TO RUNTIME;
SAVE MYSQL SERVERS TO DISK;
SELECT hostgroup_id,hostname,port,status FROM runtime_mysql_servers;

-- по какой-то причине нет группы по умолчанию ??
INSERT INTO mysql_replication_hostgroups (writer_hostgroup,reader_hostgroup,comment) VALUES (0,1,'cluster1');
LOAD MYSQL SERVERS TO RUNTIME;
SAVE MYSQL SERVERS TO DISK;

-- посмотрим на группы репликации
SELECT * FROM mysql_servers;


sudo mysql
-- добавим юзера на 
-- on pxc1, 2, 3 - достаточно на 1, т.к. мультимастер %)
-- наконец то поправили и можно использовать caching_sha2_password
-- CREATE USER 'proxysql'@'%' IDENTIFIED WITH mysql_native_password by 'Otus321$';
CREATE USER 'proxysql'@'%' IDENTIFIED WITH caching_sha2_password by 'Otus321$';
FLUSH PRIVILEGES;
SELECT * FROM mysql.user\G

-- и пропишем его в настройках on pxcps
-- !!! ProxySQL currently doesn’t encrypt passwords.
mysql -u admin -padmin -h 127.0.0.1 -P 6032

UPDATE global_variables SET variable_value='proxysql' WHERE variable_name='mysql-monitor_username';
UPDATE global_variables SET variable_value='Otus321$' WHERE variable_name='mysql-monitor_password';
-- !!! загрузим конфигурацию VARIABLES в оперативную память !!!
-- To enable monitoring of these nodes, load them at runtime:
LOAD MYSQL VARIABLES TO RUNTIME;
SAVE MYSQL VARIABLES TO DISK;
SELECT * FROM global_variables WHERE variable_name LIKE 'mysql-monitor_%';
SELECT * FROM monitor.mysql_server_connect_log ORDER BY time_start_us DESC LIMIT 6;


-- Creating ProxySQL Client User
INSERT INTO mysql_users (username,password) VALUES ('sbuser','Otus321$');
LOAD MYSQL USERS TO RUNTIME;
-- !!! чтобы не потерять текущую конфигурацию USERS, запишем ее на диск
SAVE MYSQL USERS TO DISK;

mysql -u sbuser -pOtus321$ -h 127.0.0.1 -P 6033
USE otus;
SELECT * FROM accounts;
-- не работает, что пошло не так??

# Быстрый путь
sudo mysql
CREATE USER 'sbuser'@'%' IDENTIFIED WITH mysql_native_password BY 'Otus321$';
GRANT ALL ON *.* TO 'sbuser'@'%';
FLUSH PRIVILEGES;

# Медленный путь
#CREATE USER 'sbuser'@'10.128.0.59' IDENTIFIED WITH caching_sha2_password BY 'Otus321$';
#GRANT ALL ON *.* TO 'sbuser'@'10.128.0.45';
#-- пичаль беда, что опять пошло не так??

#sudo cat /var/lib/proxysql/proxysql.log

#SELECT * FROM mysql.user;
#SELECT @@hostname;

#UPDATE mysql.user SET Host = '%' WHERE Host = '10.128.0.59';
#-- опять не работает
#GRANT ALL ON *.* TO 'sbuser'@'%';

#alter user 'sbuser'@'%' IDENTIFIED WITH mysql_native_password BY 'Otus321$';
#-- недопили caching_sha2_password %()
################
mysql -u admin -padmin -h 127.0.0.1 -P 6032

-- посмотрим на группы репликации
SELECT * FROM mysql_servers;

-- более тонкая настройка запросов
show create table mysql_query_rules;
SHOW CREATE TABLE runtime_mysql_galera_hostgroups\G

-- автоматическая настройка
-- https://proxysql.com/documentation/proxysql-configuration/

-- мониторинг прикрутим 
https://www.percona.com/software/database-tools/percona-monitoring-and-management
https://www.percona.com/blog/2017/02/24/installing-percona-monitoring-and-management-pmm-for-the-first-time-2/

# Incremental State Transfer (IST)
https://www.percona.com/blog/tracking-ist-progress-in-percona-xtradb-cluster/
# State Snapshot Transfer (SST)
https://docs.percona.com/percona-xtradb-cluster/8.0/state-snapshot-transfer.html


