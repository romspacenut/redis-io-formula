include:
  - redis-io.common

{%- from "redis-io/map.jinja" import redis_settings with context %}

/var/log/redis/sentinel.log:
  file.managed:
    - user: {{ redis_settings.user }}
    - makedirs: True
    - require:
      - user: redis-user

{{ redis_settings.sentinel.cfg_file }}:
  file.managed:
    - user: {{ redis_settings.user }}
    - mode: 755
    - makedirs: True
    - template: jinja
    - source: salt://redis-io/files/sentinel.conf.jinja
    - require:
      - file: download-redis-io
    - default:
      sentinel: {{ redis_settings.sentinel }}

/etc/init.d/redis-sentinel:
  file.managed:
    - mode: 755
    - makedirs: True
    - template: jinja
    - source: salt://redis-io/files/redis-sentinel.jinja
    - default:
      sentinel: {{ redis_settings.sentinel }}
      settings: {{ redis_settings }}


#service-redis-sentinel:
#  service.running:
#    - name: redis-sentinel
#    - enable: True
#    - reload: True
#    - restart: True
#    - watch:
#      - file: /etc/redis/sentinel.conf