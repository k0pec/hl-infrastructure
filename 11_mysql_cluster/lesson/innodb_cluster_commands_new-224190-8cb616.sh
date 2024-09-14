################## MySQL InnoDB Cluster #############################33333
#### Зависимость - нужен рабочий DNS между машинами
sudo nano /etc/hosts
10.0.26.101 mysql-cluster1
10.0.26.102 mysql-cluster2
10.0.26.103 mysql-cluster3

# Устанавливаем репозиторий
wget https://dev.mysql.com/get/mysql-apt-config_0.8.28-1_all.deb; dpkg -i mysql-*.deb
sudo apt install mysql-shell mysql-server -y
# Root password из ansible: 1

# Начальная конфигурация нод - на mysql-cluster1
# Выход из MySQL shell - \q
sudo mysqlsh
-- сконфигурируем инстанс, заодно включатся GTID и т.д.
dba.configureInstance('mysql-cluster1',{clusterAdmin: "clusteradmin@'%'",clusterAdminPassword: 'Otus321$'});

Please provide the password for 'root@mysql-cluster1': *
Save password for 'root@mysql-cluster1'? [Y]es/[N]o/Ne[v]er (default No): Y
NOTE: Some configuration options need to be fixed:
....
Found configuration file being used by instance 'mysql-cluster1:3306' at location: /etc/mysql/my.cnf
Do you want to modify this file? [y/N]: y
Do you want to perform the required configuration changes? [y/n]: y
Do you want to restart the instance after configuring it? [y/n]: y
...
Restarting MySQL...
NOTE: MySQL server at mysql-cluster1:3306 was restarted.

-- Повторяем это на других нодах (меняем только имя хоста, логины и пароли должны быть одинаковыми)
-- Или делаем с ноды mysql-cluster1
dba.configureInstance('root@mysql-cluster2',{clusterAdmin: "clusteradmin@'%'",clusterAdminPassword: 'Otus321$'});
dba.configureInstance('root@mysql-cluster3',{clusterAdmin: "clusteradmin@'%'",clusterAdminPassword: 'Otus321$'});

# https://dev.mysql.com/doc/mysql-shell/8.4/en/configuring-production-instances.html

#### Создаём кластер
-- На mysql-cluster1
shell.connect('clusteradmin@mysql-cluster1:3306');
# Password: Otus321$

cluster = dba.createCluster('my_innodb_cluster');
# Выбираем Clone
cluster.addInstance('clusteradmin@mysql-cluster2:3306');
cluster.addInstance('clusteradmin@mysql-cluster3:3306');
cluster.status()

# Кластер собран и работает
{
    "clusterName": "my_innodb_cluster", 
    "defaultReplicaSet": {
        "name": "default", 
        "primary": "mysql-cluster1:3306", 
        "ssl": "REQUIRED", 
        "status": "OK", 
        "statusText": "Cluster is ONLINE and can tolerate up to ONE failure.", 
        "topology": {
            "mysql-cluster1:3306": {
                "address": "mysql-cluster1:3306", 
                "memberRole": "PRIMARY", 
                "mode": "R/W", 
                "readReplicas": {}, 
                "replicationLag": "applier_queue_applied", 
                "role": "HA", 
                "status": "ONLINE", 
                "version": "8.0.37"
            }, 
            "mysql-cluster2:3306": {
                "address": "mysql-cluster2:3306", 
                "memberRole": "SECONDARY", 
                "mode": "R/O", 
                "readReplicas": {}, 
                "replicationLag": "applier_queue_applied", 
                "role": "HA", 
                "status": "ONLINE", 
                "version": "8.0.37"
            }, 
            "mysql-cluster3:3306": {
                "address": "mysql-cluster3:3306", 
                "memberRole": "SECONDARY", 
                "mode": "R/O", 
                "readReplicas": {}, 
                "replicationLag": "applier_queue_applied", 
                "role": "HA", 
                "status": "ONLINE", 
                "version": "8.0.37"
            }
        }, 
        "topologyMode": "Single-Primary"
    }, 
    "groupInformationSourceMember": "mysql-cluster1:3306"
}

\sql
show variables like 'group_replication%';

# Получить переменную для управления существующим кластером
cluster = dba.getCluster()
#-- разобрать кластер
#cluster.dissolve({force:true})

-- для переключения в режим MM cluster.switchToMultiPrimaryMode()

################################################################################

# Работаем с данными по SQL
shell.connect('clusteradmin@mysql-cluster1:3306');
\sql

show databases;
use performance_schema
show tables;
select * from replication_group_member_stats\G

show grants for clusteradmin@'%';
GRANT ALL ON *.* TO clusteradmin@'%';

# Даём права на работу со всеми БД
sudo mysql -p
GRANT ALL ON *.* TO clusteradmin@'%';

-- on mysql-cluster2
shell.connect('clusteradmin@mysql-cluster2:3306');
\sql
select * from mysql.user\G

-- не получится, т.к. R/O
create database otus;

-- on mysql-cluster1
mysqlsh
shell.connect('clusteradmin@mysql-cluster1:3306');
\sql
create database otus;
use otus;
CREATE TABLE accounts (
    id SERIAL,
    balance DECIMAL
);
insert into accounts(balance) values ('10.0'), ('20.0');
select * from accounts; 

-- on mysql-cluster2
show databases;

#-- switch to MultiMaster - нет особого смысла
#cluster = dba.getCluster()
#cluster.switchToMultiPrimaryMode()

######### MySQL Router #############################################################################
# Стаим либо на PRIMARY, либо на хост с приложением
-- установим роутер
https://dev.mysql.com/doc/mysql-router/8.0/en/mysql-router-installation.html

sudo apt install mysql-router -y

-- бутстрапим
-- https://dev.mysql.com/doc/mysql-router/8.0/en/mysql-router-deploying-bootstrapping.html

#mysqlrouter --bootstrap root@localhost --directory /tmp/myrouter --conf-use-sockets --account routerfriend --account-create always
#-- fail - нужен или чистый инстанс или мастер нода

mysqlrouter --bootstrap clusteradmin@localhost --directory /tmp/myrouter --conf-use-sockets --account routerfriend --account-create always
# Pass: Otus321$
#Please enter MySQL password for routerfriend: 
#Fetching Cluster Members
#trying to connect to mysql-server at mysql-cluster2:3306

# MySQL Router configured for the InnoDB Cluster 'my_innodb_cluster'

#After this MySQL Router has been started with the generated configuration

#    $ mysqlrouter -c /tmp/myrouter/mysqlrouter.conf

#InnoDB Cluster 'my_innodb_cluster' can be reached by connecting to:

# Подключаемся в режиме Read/Write
mysql -P 6446 -u root -p

-- to Master Slave
shell.connect('clusteradmin@mysql-cluster1:3306');
cluster = dba.getCluster()
cluster.switchToSinglePrimaryMode('mysql-cluster1:3306')

# Восстановление кластера
sudo mysqlsh
shell.connect('clusteradmin@mysql-cluster1:3306');
dba.rebootClusterFromCompleteOutage()
cluster = dba.getCluster()
cluster.rescan()
