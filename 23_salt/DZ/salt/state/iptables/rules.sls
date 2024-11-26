---
iptables:
  pkg:
    - installed
  service.running:
    - watch:
        - file: /etc/sysconfig/iptables
    - enable: true

/etc/sysconfig/iptables:
  file.managed:
    - source: salt://iptables/iptables
    - show_changes: false