---
nginx:
  pkg:
    - installed
  service.running:
    - watch:
        - file: /etc/nginx/nginx.conf
    - enable: true

/etc/nginx/nginx.conf:
  file.managed:
    - source: salt://nginx/nginx.conf
    - show_changes: false

