---

epel:
  pkgrepo.managed:
    - enabled: 1 
    - humanname: 'Extra Packages for Enterprise Linux 7 - $basearch'
    - mirrorlist: 'https://mirrors.fedoraproject.org/metalink?repo=epel-7&arch=$basearch'
    - gpgcheck: 0

nginx:
  pkg:
    - installed
  service.running:
    - watch:
        - file: /etc/nginx/nginx.conf
    - enable: true


/srv/www/site/index.html:
  file.managed:
    - source: salt://nginx/site_html.jinja
    - template: jinja
    - makedirs: true
    - show_changes: false

/etc/nginx/nginx.conf:
  file.managed:
    - source: salt://nginx/nginx.conf
    - show_changes: false

