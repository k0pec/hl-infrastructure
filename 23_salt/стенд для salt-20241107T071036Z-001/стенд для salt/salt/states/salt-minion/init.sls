salt-minion:
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
