postgresql11:
  pkg:
    - installed

{% if salt['cmd.shell']('ls -A /var/lib/pgsql/11/data/ | wc -l') == '0' %}
pgdb-init:
  cmd.run:
    - name: /usr/pgsql-11/bin/postgresql-11-setup initdb

postgresql11-server:
  pkg:
    - installed
    - fromrepo: pgdg11
  service:
    - name: postgresql-11
    - running
    - enable: True

{% endif %}
