# HashiCorp Consul 

##  Prepare Docker for Demo
```bash
# https://docs.docker.com/desktop/release-notes/
# consul tls ca create
# consul tls cert create -server -dc dc1

# Templetes:
# https://learn.hashicorp.com/tutorials/consul/docker-compose-datacenter?in=consul/docker
# cd ~/Otus/HL-Linux/Consul/Demo
# git clone https://github.com/hashicorp/learn-consul-docker.git ~/Otus/HL-Linux/Consul/Demo/templetes
# mkdir ./cnsl-nginx
# cp -R learn-consul-docker/datacenter-deploy-secure/* ./cnsl-nginx

https://hashicorp-releases.yandexcloud.net/consul/

```

## Install Needs Packages
```bash
cd ~/Otus/HL-Linux/Consul/Demo/cnsl-nginx
docker compose -f ~/Otus/HL-Linux/Consul/Demo/cnsl-nginx/docker-compose-init.yml ps
docker compose -f ~/Otus/HL-Linux/Consul/Demo/cnsl-nginx/docker-compose-init.yml up -d
docker compose -f ~/Otus/HL-Linux/Consul/Demo/cnsl-nginx/docker-compose-init.yml down

docker exec -it nginx0-init /bin/bash

apt-get update && apt-get install -y gnupg2 lsb-release software-properties-common procps dnsutils sudo mc jq nano wget curl nginx && apt-get clean all

# https://hashicorp-releases.yandexcloud.net/consul/
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg \
  && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list \
  && sudo apt update && sudo apt install consul

# https://hashicorp-releases.yandexcloud.net/consul-template/
export VER='0.30.0'
cd /mnt
curl -O https://releases.hashicorp.com/consul-template/${VER}/consul-template_${VER}_linux_amd64.zip
unzip consul-template_${VER}_linux_amd64.zip -d /usr/bin

systemctl enable consul
systemctl start consul
systemctl status consul

systemctl enable nginx
systemctl start nginx
systemctl status nginx

docker ps -a
# docker export ccf0186fc971 > ~/Otus/HL-Linux/Consul/Demo/consul_nginx
# docker import ~/Otus/HL-Linux/Consul/Demo/consul_nginx consul_nginx:latest
docker commit 8bfa2c3d0401 consul-nginx
docker save -o ~/Otus/HL-Linux/Consul/Demo/consul_nginx 472ed33db03b
# docker load -i ~/Otus/HL-Linux/Consul/Demo/consul_nginx
docker tag c3fdfa2a4a6d consul-nginx:latest
```

## Install Consul
https://www.consul.io/downloads
https://www.consul.io/docs/install


```bash
cd ~/Otus/HL-Linux/Consul/Demo/cnsl-nginx
docker compose up -d
docker compose exec nginx3 /bin/bash
#systemctl list-units --type service --state running
systemctl status consul
cat /etc/os-release

curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
# Warning: apt-key is deprecated. Manage keyring files in trusted.gpg.d instead (see apt-key(8)).
# curl: (22) The requested URL returned error: 403
# gpg: no valid OpenPGP data found.

# apt-key list
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    && sudo apt-get update && sudo apt-get install consul
# Err:5 https://apt.releases.hashicorp.com bullseye InRelease
#   403  Forbidden [IP: 13.33.243.34 443]

#ls -l /usr/bin/consul

consul -v
consul members

# systemctl list-units --type service --state running
# systemctl status consul

nano /usr/lib/systemd/system/consul.service
# ConditionFileNotEmpty=/etc/consul.d/consul.hcl
ls -lh /etc/consul.d/

systemctl enable consul
systemctl start consul

consul members
consul operator raft list-peers
consul info
#reboot

# Запустить агента в режиме отладки
/usr/bin/consul agent -dev -config-dir=/etc/consul.d/
```

## Config Consul
https://www.consul.io/docs/agent/options
https://www.consul.io/docs/install/ports

```bash
cd ~/Otus/HL-Linux/Consul/Demo/cnsl-nginx
docker compose exec nginx3 /bin/bash
cat /etc/consul.d/nginx3.json | jq
cat /etc/consul.d/consul.hcl
exit

docker compose exec consul-server1 /bin/sh
cat /consul/config/server1.json | jq
# docker compose exec consul-server1 consul members

consul validate /consul/config/
consul reload
```

## Register a Service
https://developer.hashicorp.com/consul/docs/services/services
https://developer.hashicorp.com/consul/docs/services/usage/register-services-checks

http://localhost:8500/ui/dc1/nodes

```bash
# На узле 1 - 2
    docker compose exec nginx2 /bin/bash
    ls -l /etc/consul.d/
    echo '{
        "service": {
            "id": "web",
            "name": "web",
            "tags": [ "nginx" ],
            "port": 80,
            "enable_tag_override": false,
            "check": {
                "id": "web_up",
                "name": "nginx healthcheck",
                "args": ["curl", "localhost"],
                "interval": "10s",
                "timeout": "2s"
            }
        }
    }' > /etc/consul.d/web.json
    # cat /etc/consul.d/web.json
    consul validate /etc/consul.d/
    consul reload
    exit
    
# На узле 3
    docker compose exec nginx3 /bin/bash
    ls -l /etc/consul.d/
    echo '{
        "service": {
            "id": "web",
            "name": "web",
            "tags": [ "nginx" ],
            "port": 80,
            "enable_tag_override": false,
            "check": {
                "id": "web_up",
                "name": "nginx healthcheck",
                "tcp": "localhost:80",
                "interval": "10s",
                "timeout": "2s"
            }
        }
    }' > /etc/consul.d/web.json
    # cat /etc/consul.d/web.json
    consul validate /etc/consul.d/
    consul reload
    exit
```

## DNS Interface
https://www.hashicorp.com/blog/load-balancing-strategies-for-consul
https://www.consul.io/use-cases/load-balancing
https://www.consul.io/docs/discovery/dns

```bash
docker compose exec nginx3 /bin/bash
dig @localhost -p 8600 consul-server1.node.dc1.consul
dig @localhost -p 8600 -x 172.19.0.5

dig @127.0.0.1 -p 8600 web.service.consul
# dig @localhost -p 8600 web.service.dc1.consul
dig @127.0.0.1 -p 8600 web.service.consul SRV
# dig @localhost -p 8600 web.service.dc1.consul SRV
dig @127.0.0.1 -p 8600 nginx.web.service.consul
# dig @localhost -p 8600 nginx.web.service.dc1.consul

https://developer.hashicorp.com/consul/tutorials/networking/dns-forwarding#dnsmasq-setup
https://www.dmosk.ru/miniinstruktions.php?mini=consul-connect-mesh
curl http://localhost:8500/v1/catalog/nodes\?pretty
ping -c 5 172.19.0.2
nslookup web.service.consul 127.0.0.1 -port=8600
ping web.service.consul
```

## Test a Service
```bash
http://localhost:8500/ui/dc1/services
cd ~/Otus/HL-Linux/Consul/Demo/cnsl-nginx

# bind volume index.html
# docker compose exec nginx1 /bin/bash
# На каждом узле
    echo '<!DOCTYPE html>
    <html>
    <body>
    nginx-01
    </body>
    </html>' > /var/www/html/index.html

docker compose exec nginx1 /bin/bash
### Тест на вывод Curl
while true
do curl -s $(dig +short @localhost -p 8600 web.service.dc1.consul | head -n1) | grep nginx
sleep .5
done

### Тест на количество нод
while true
do dig +short @localhost -p 8600 web.service.dc1.consul | wc -l
sleep .5
done

cd ~/Otus/HL-Linux/Consul/Demo/cnsl-nginx
docker compose exec nginx3 /bin/bash
systemctl stop nginx
systemctl status nginx
systemctl start nginx
```

## (De)Register a Service
cd ~/Otus/HL-Linux/Consul/Demo/cnsl-nginx
docker compose exec nginx3 /bin/bash
consul catalog services
consul services deregister -id=web
consul services register -id=web -name=web
consul reload



## HTTP API
https://www.consul.io/api-docs
```bash
curl http://localhost:8500/v1/agent/members\?pretty | jq
curl http://localhost:8500/v1/agent/checks\?pretty
curl http://localhost:8500/v1/agent/services\?pretty
curl http://localhost:8500/v1/catalog/services\?pretty
curl http://localhost:8500/v1/catalog/service/web\?pretty | jq

curl http://localhost:8500/v1/catalog/nodes\?pretty
curl http://localhost:8500/v1/health/service/web?passing | jq

#curl http://localhost:8500/v1/agent/members | jq
#curl --get localhost:8500/v1/agent/members --data-urlencode 'filter=Name == "consul-server1"' | jq

curl -XPUT http://localhost:8500/v1/kv/nginx/config/workers -d 10
curl -XGET http://localhost:8500/v1/kv/nginx/config/workers | jq
curl -XDELETE http://localhost:8500/v1/kv/nginx/config/workers
```

## KV Store
```bash
https://learn.hashicorp.com/tutorials/consul/get-started-key-value-store?in=consul/getting-started
https://www.consul.io/commands/kv/put

consul kv put nginx/config/workers 10
consul kv get nginx/config/workers

Ключи поддерживают установку 64-битного целочисленного значения флага, которое не используется внутри Consul, но может использоваться клиентами для добавления метаданных к любой паре KV.
consul kv put -flags=42 nginx/test/test abcd1234
consul kv get --detailed nginx/test/test

consul kv get --recurse
consul kv get --recurse nginx/test

consul kv delete nginx/test
consul kv delete --recurse nginx/test

consul kv export nginx > /tmp/consul_nginx_dmp.json
cat /tmp/consul_nginx_dmp.json | jq

consul kv delete --recurse nginx/
consul kv get --recurse
consul kv import @/tmp/consul_nginx_dmp.json
consul kv get --recurse

# versioning
# https://developer.hashicorp.com/vault/docs/commands/kv/enable-versioning
# https://discuss.hashicorp.com/t/versioned-key-value-in-consul-kv/37390
# consul kv put nginx/test 1
# consul kv get nginx/test
# consul kv enable-versioning enable-versioning nginx/test
# consul kv put nginx/test 2

# Check-And-Set 
# Чтобы обновить ключ только в том случае, если он не был изменен с момента указанного индекса, укажите флаги -cas и -modify-index:
consul kv put redis/config/connections 8
consul kv get -detailed redis/config/connections | grep ModifyIndex
consul kv put -cas -modify-index=700 redis/config/connections 15
consul kv put -cas -modify-index=844 redis/config/connections 10
consul kv get -detailed redis/config/connections
consul kv get -keys

# Locking Primitives
# Чтобы создать или настроить блокировку, используйте флаги -acquire и -session. Сессия должна уже существовать (эта команда не будет ее создавать или управлять):
https://www.consul.io/api-docs/session

echo '{
  "LockDelay": "15s",
  "Name": "my-service-lock",
  "Node": "nginx3",
  "Checks": ["web_up"],
  "Behavior": "release",
  "TTL": "30s"
}' > /mnt/payload.json
curl --request PUT --data @/mnt/payload.json http://127.0.0.1:8500/v1/session/create

curl http://127.0.0.1:8500/v1/session/list | jq
consul kv put -acquire -session=9a10244b-57dd-64cd-eb1c-2e8f184d65f1 redis/lock/update
consul kv put -release -session=9a10244b-57dd-64cd-eb1c-2e8f184d65f1 redis/lock/update
```

## Watches
cd ~/Otus/HL-Linux/Consul/Demo/cnsl-nginx
docker compose exec nginx3 /bin/bash
```bash
echo '{
    "watches": [
        {
            "type": "key",
            "key": "nginx/config/enabled",
            "handler_type": "script",
            "args": ["/opt/consul/nginx.sh"]
        }
    ]
}' > /etc/consul.d/watch.json

echo '#!/bin/bash
NEW_STATE=$(consul kv get nginx/config/enabled)

if [[ $NEW_STATE == "true" ]]; then
    logger "start nginx";
    sudo systemctl start nginx;
else
    logger "stop nginx"
    sudo systemctl stop nginx;
fi
' > /opt/consul/nginx.sh

# cat /opt/consul/nginx.sh
# nano /opt/consul/nginx.sh
chmod 700 /opt/consul/nginx.sh
chown consul.consul /opt/consul/nginx.sh

#su -s /bin/bash -c '/opt/consul/nginx.sh' consul
nano /etc/sudoers
# Consul
consul ALL=(ALL) NOPASSWD: /bin/systemctl start nginx
consul ALL=(ALL) NOPASSWD: /bin/systemctl stop nginx

# ls -lh /etc/consul.d/
consul validate /etc/consul.d/
consul reload

#consul watch -type=key -key=nginx/config/enabled /opt/consul/nginx.sh &

consul kv get nginx/config/enabled
consul kv put nginx/config/enabled true
consul kv put nginx/config/enabled false

journalctl -xe -u nginx
```

## Consul-Template
Демон, который формирует файлы из подготовленных шаблонов и сведений, получаемых при опросе кластера Consul. В дополнение к этому, он может выполнять некоторые команды, когда сформирован очередной шаблон; к примеру, может перезапускать сервис. https://github.com/hashicorp/consul-template
Для написания шаблонов используется Template Language, который вкл􏰀чает 4 группы функций:
API functions (обращение к Consul);
scratchpad (промежуточное хранение данных);
helper functions (вспомогательные функции для разбора данных, форматирования и т.п.);
math functions.
https://learn.hashicorp.com/tutorials/consul/consul-template
https://learn.hashicorp.com/tutorials/consul/load-balancing-nginx
https://github.com/hashicorp/consul-template/blob/main/docs/templating-language.md

### Install 
```bash
cd ~/Otus/HL-Linux/Consul/Demo/cnsl-nginx
docker compose exec nginx3 /bin/bash

# https://hashicorp-releases.yandexcloud.net/consul-template/
# export VER='0.29.6'
consul-template -v
export VER='0.39.1'

cd /tmp
# curl -O https://releases.hashicorp.com/consul-template/${VER}/consul-template_${VER}_linux_amd64.zip
wget -O consul-template_${VER}_linux_amd64.zip https://hashicorp-releases.yandexcloud.net/consul-template/${VER}/consul-template_${VER}_linux_amd64.zip
unzip consul-template_${VER}_linux_amd64.zip -d /usr/bin

ls -lh /usr/bin | grep consul
consul-template -v

mkdir -p /etc/consul-template.d
nano /etc/consul-template.d/config.hcl
------------------------------------------------------------------------
consul {
  address = "localhost:8500"

  retry {
    enabled  = true
    attempts = 12
    backoff  = "250ms"
  }
}
template {
  source      = "/etc/consul-template.d/nginx.ctmpl"
  destination = "/etc/nginx/nginx.conf"
  perms       = 0600
  command     = "sudo systemctl stop nginx && sudo systemctl start nginx"
}
------------------------------------------------------------------------

cat /etc/nginx/nginx.conf
cp /etc/nginx/nginx.conf /etc/consul-template.d/nginx.ctmpl
chown -R consul:consul /etc/consul-template.d

nano /etc/consul-template.d/nginx.ctmpl
------------------------------------------------------------------------
# worker_processes  auto;
worker_processes {{ key "nginx/config/workers" }};
------------------------------------------------------------------------

nano /usr/lib/systemd/system/consul-template.service
-----------------------------------------------------------------------------
[Unit]
Description="HashiCorp Consul-Template"
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target

[Service]
ExecStart=/usr/bin/consul-template -config=/etc/consul-template.d/config.hcl
KillSignal=SIGINT
SuccessExitStatus=12

Restart=always
RestartSec=30

[Install]
WantedBy=multi-user.target
-----------------------------------------------------------------------------

systemctl daemon-reload
systemctl start consul-template
systemctl status consul-template # подождать
# systemctl stop consul-template

systemctl status nginx
head -n20 /etc/nginx/nginx.conf

consul kv get nginx/config/workers
consul kv put nginx/config/workers 5
head -n20 /etc/nginx/nginx.conf
systemctl status nginx
```

## Test Cluster

### Stops Nodes
```bash
cd ~/Otus/HL-Linux/Consul/Demo/cnsl-nginx

# Client
docker compose exec nginx1 /bin/bash
consul members
consul operator raft list-peers

# Node-3
# docker compose exec consul-server3 /bin/sh
docker-compose stop consul-server3

# Client
consul members
consul operator raft list-peers
# consul kv get nginx/config/enabled

# Node-2
docker-compose stop consul-server1

# Client
consul members
consul operator raft list-peers

# Node-3
docker-compose stop consul-server2 # not leader

# Client
consul members
consul operator raft list-peers

# Node-2
docker-compose start consul-server2

# Client
consul members
consul operator raft list-peers
```

### Add/Join Nodes
https://learn.hashicorp.com/tutorials/consul/add-remove-servers

```bash
cd ~/Otus/HL-Linux/Consul/Demo/cnsl-nginx

docker compose exec consul-server1 /bin/sh
while true
do consul operator raft list-peers
sleep .5
done

# On consul-server4
cd ~/Otus/HL-Linux/Consul/Demo/cnsl-nginx
docker compose exec consul-server4 /bin/sh
# consul -v
consul members
consul operator raft list-peers

#ls -l /consul/config/
cat /consul/config/server4.json

consul join consul-server3 # leader
consul leave

docker compose exec consul-server4 /bin/sh
consul members
consul join consul-server1 # not leader

# consul validate /consul/config/
# consul agent -config-dir=/consul/config/
# consul join -ca-file='/consul/config/certs/consul-agent-ca.pem' \
#     -ca-path='/consul/config/certs/' \
#     -client-cert='/consul/config/certs/dc1-server-consul-0.pem' \
#     -client-key='/consul/config/certs/dc1-server-consul-0-key.pem' \
#     -token='aPuGh+5UDskRAbkLaXRzFoSOcSM+5vAK+NEYOWHJH7w=' \
#     consul-server2
```

## Backup / Restore
На что обратить внимание:
важна директория data-dir на server'ах;
на client ничего интересного нет;
бекап выполняется получанием snapshot с leader;
snapshot не выполняется, если кластер degraded;
snapshot не выполняется, если нет leader;
можно снять не с leader, но данные будут устаревшими;
при snapshot часть самых свежих данных может не попасть в снимок, т.к. они ещё не были согласованы (около 100ms), но для аварийного восстановления это, обычно, уже не имеет значения :)


```bash
cd ~/Otus/HL-Linux/Consul/Demo/cnsl-nginx

docker compose exec consul-server2 /bin/sh

consul operator raft list-peers
consul snapshot save /consul/backup.snap # on leader
#consul snapshot save -stale /consul/backup.snap # on leader
consul snapshot inspect /consul/backup.snap
# less /consul/backup.snap
# file /consul/backup.snap

consul kv get --recurse
consul kv delete --recurse nginx
consul kv get --recurse
consul snapshot restore /consul/backup.snap
consul kv get --recurse
exit
```

# Demo
https://demo.consul.io/ui/dc1/nodes


# Clear
docker compose -f ~/Otus/HL-Linux/Consul/Demo/cnsl-nginx/docker-compose.yml down


Split-Brain Consul
https://support.hashicorp.com/hc/en-us/articles/360058026733-Identifying-and-Recovering-from-a-Consul-Split-Brain