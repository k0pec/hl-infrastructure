erick:
  user:
    - present
    - fullname: Arais Erick
    {% if grains['os_family'] == 'FreeBSD' %}
    - shell: /usr/local/bin/bash
    - home: /usr/home/erick
    {% else %}
    - shell: /bin/bash
    - home: /home/erick
    {% endif %}
    - groups:
    {% if grains['os_family'] == 'Debian' %}
      - sudo
    {% elif grains['os_family'] == 'RedHat' %}
      - wheel
    {% else %}
      - sudo
    {% endif %}

### Каталог для размещения ключа ssh
{% if not salt['file.directory_exists']('/home/erick/.ssh') %}
/home/erick/.ssh:
  file.directory:
    - name: /home/erick/.ssh
    - user: erick
    - group: erick
    - mode: 700
{% endif %}

erick_key:
  ssh_auth:
    - present
    - user: erick
    - enc: ssh-rsa
    - source: salt://sudo-tech/erick-key
