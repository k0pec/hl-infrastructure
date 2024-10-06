Zookeeper
=========
This is the Ansible role for installing Zookeeper.

## Dependencies
- ansible >= 2.0

## Usage

```
#requirements.yml
---
- src: https://github.com/samitpatel/ansible-zookeeper.git
  name: zookeeper

#/bin/bash
> ansible-galaxy install -r requirements.yml

#playbook.yml
---
- hosts: all
  become: true
  become_method: sudo
  serial: 1
  roles:
    - zookeeper

#/bin/bash
> ansible-playbook -i inventory playbook.yml --tags deploy

Available tags:
deploy - Install, configures and starts zookeeper
restart - Restarts zookeeper service
configure - Configures zookeeper
stop - Stops zookeeper service
```

## Security Features

### Authentication:
Zookeeper support SASL authentication.

```
- hosts: all
  become: true
  become_method: sudo
  serial: 1
  roles:
    - zookeeper
  vars:
    # SASL Authentication
    - zookeeper_sasl_enable: true
    - zookeeper_auth_provider_1: 'org.apache.zookeeper.server.auth.SASLAuthenticationProvider'
    - zookeeper_require_client_auth_scheme: 'sasl'
    - zookeeper_jaas_login_renew: '3600000'
    - zookeeper_admin_password: 'admin-secret'
    - zookeeper_users:
      - foo: 'boo'
    - zookeeper_jvm_flags: "-Djava.security.auth.login.config={{zookeeper_conf_dir}}/zookeeper_server_jaas.conf"
```

### Sample JAAS config file:
Server
```
Server {
  org.apache.zookeeper.server.auth.DigestLoginModule required
  user_admin="admin-secret"
  user_foo="bar";
};
```

Client
```
Client {
  org.apache.zookeeper.server.auth.DigestLoginModule required
  username="foo"
  password="bar";
};
```
