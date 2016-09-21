include:
  - redis-io.common

{%- from "redis-io/map.jinja" import redis_settings with context %}
{%- set version = redis_settings.version|default('3.2.3') %}
{%- set root    = redis_settings.root|default('/usr/local') %}
{%- set nodes   = salt['pillar.get']('redis_io:nodes', {'6379': []}) %}

/usr/local/redis-{{ version }}/utils/install_server.sh:
  file.exists

redis-io-group:
  group.present:
    - name: {{ redis_settings.group }}

redis-io-user:
  user.present:
    - name: {{ redis_settings.user }}
    - gid_from_name: True
    - home: {{ redis_settings.home }}
    - groups:
      - {{ redis_settings.group }}
    - require:
      - group: redis-io-group

{%- for redis_port, node_cfg in nodes.items() %}
# run install_server.sh
install-server-{{ redis_port }}:
  cmd.run:
    - name: printf '{{ redis_port }}\n/etc/redis/{{ redis_port }}.conf\n/var/log/redis_{{ redis_port }}.log\n/var/lib/redis/{{ redis_port }}\n/usr/local/bin/redis-server' | ./install_server.sh
    - cwd: /usr/local/redis-{{ version }}/utils
    - unless: test -f /etc/redis/{{ redis_port }}.conf
    - require:
      - file: /usr/local/redis-{{ version }}/utils/install_server.sh

# Generate conf
/etc/redis/{{ redis_port }}.conf:
  file.managed:
    - makedirs: True
    - template: jinja
    - source: salt://redis-io/files/redis.conf.jinja
    - user: {{ redis_settings.user }}
    - group: {{ redis_settings.group }}
    - default:
      default_cfg: {{ redis_settings }}
      node_cfg: {{ node_cfg }}
      port: {{ redis_port }}
# Need to use onchanges that's available with 2016.3.x
  cmd.run:
    - onlyif: ps xawww | grep ":{{ redis_port }}" | grep -v "grep"
    - name: service redis_{{ redis_port }} stop
#    - watch:
#      - file: /etc/redis/{{ redis_port }}.conf

redis_{{ redis_port }}:
  service.running:
    - name: redis_{{ redis_port }}
    - sig: redis-server {{ node_cfg.bind|default(redis_settings.bind) }}:{{ redis_port }}
    - enable: True
    - reload: True
    - require:
      - cmd: build-redis-io
    - watch:
      - file: /etc/redis/{{ redis_port }}.conf
{% endfor %}