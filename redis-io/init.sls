include:
  - redis-io.common

{%- from "redis-io/map.jinja" import redis_settings with context %}
{%- set version = redis_settings.version|default('3.2.3') %}
{%- set root    = redis_settings.root|default('/usr/local') %}

/usr/local/redis-{{ version }}/utils/install_server.sh:
  file.exists

{%- for redis_port, port_config in redis_settings.nodes.items() %}

{%- if port_config %}
{%- set config = port_config %}
{%- else %}
{%- set config = redis_settings %}
{%- endif %}

redis-group:
  group.present:
    - name: {{ redis_settings.group }}

redis-user:
  user.present:
    - name: {{ redis_settings.user }}
    - gid_from_name: True
    - home: {{ redis_settings.home }}
    - groups:
      - {{ redis_settings.group }}
    - require:
      - group: redis_group

# run install_server.sh
install-server-{{ redis_port }}:
  cmd.run:
    - name: printf '{{ redis_port }}\n/etc/redis/{{ redis_port }}.conf\n/var/log/redis_{{ redis_port }}.log\n/var/lib/redis/{{ redis_port }}\n/usr/local/bin/redis-server' | ./install_server.sh
    - cwd: /usr/local/redis-{{ version }}/utils
    - unless: test -f /etc/redis/{{ redis_port }}.conf
    - require:
      - file: /usr/local/redis-{{ version }}/utils/install_server.sh

# Generate conf
config-redis-{{ redis_port }}:
  file.managed:
    - name: /etc/redis/redis_{{ redis_port }}.conf
    - user: redis
    - group: redis
    - mode: 755
    - makedirs: True
    - template: jinja
    - source: salt://redis-io/files/redis.conf.jinja
#    - require_in:
#      service: /etc/init.d/service-redis-node-{{ redis_port }}
#    - require:
#      - file: redis-conf-dir-{{ redis_port }}
#      - cmd: redis-old-init-disable
    - default:
      config: {{ config }}
      port: {{ redis_port }}
  service.running:
    - name: redis_{{ redis_port }}
    - sig: redis-server {{ config.bind }}:{{ redis_port }}
    - enable: True
    - reload: True
    - require:
      - cmd: build-redis-io
    - watch:
      - file: config-redis-{{ redis_port }}

{% endfor %}