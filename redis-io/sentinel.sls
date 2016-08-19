include:
  - redis-io.common

{%- from "redis-io/map.jinja" import redis_settings with context %}

/etc/redis/sentinel.conf:
  file.managed:
#    - user: redis
    - mode: 755
    - makedirs: True
    - template: jinja
    - source: salt://redis-io/files/sentinel.conf.jinja
    - require:
      - file: download-redis-io
    - default:
      sentinel: {{ redis_settings.sentinel }}

#service-redis-sentinel:
#  service.running:
#    - name: redis-sentinel
#    - enable: True
#    - reload: True
#    - restart: True
#    - watch:
#      - file: /etc/redis/sentinel.conf