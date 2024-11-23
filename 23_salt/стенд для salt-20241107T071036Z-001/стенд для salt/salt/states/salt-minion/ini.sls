salt-minion:
  pkgrepo.managed:
     - name: salt-latest
     - humanname: Salt repo for RHEL/CentOS
     - baseurl: https://repo.saltproject.io/py3/redhat/$releasever/$basearch/latest
     - gpgkey: https://repo.saltproject.io/py3/redhat/$releasever/$basearch/latest/SALTSTACK-GPG-KEY.pub
     - gpgcheck: 1
     - enabled: 1

  pkg:
    - installed
    - require:
      - pkgrepo: salt-latest

  service:
      - running
      - enable: True
      - require:
        - pkg: salt-minion
      - watch:
          - file: /etc/salt/minion


/etc/salt/minion:
  file:
    - source: salt://salt-minion/minion
    - managed
    - user: root
    - group: root
    - mode: 0644
    - template: jinja
