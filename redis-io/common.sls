{%- from "redis-io/map.jinja" import redis_settings with context %}
{%- set version       = redis_settings.version|default('3.2.3') %}
{%- set file_checksum = redis_settings.file_checksum|default('sha1=92d6d93ef2efc91e595c8bf578bf72baff397507') %}
{%- set root          = redis_settings.root|default('/usr/local') %}

redis-io-dependencies:
  pkg.installed:
    - names:
      {% if grains['os_family'] == 'RedHat' %}
      - python-devel
      - make
      - libxml2-devel
      {% elif grains['os_family'] == 'Debian' or 'Ubuntu' %}
      - build-essential
      - python-dev
      - libxml2-dev
     {% endif %}

download-redis-io:
  file.managed:
    - name: {{ root }}/redis-{{ version }}.tar.gz
    - source: http://download.redis.io/releases/redis-{{ version }}.tar.gz
    - source_hash: {{ file_checksum }}
    - require:
      - pkg: redis-io-dependencies
  cmd.wait:
    - cwd: {{ root }}
    - names:
      - tar -zxvf {{ root }}/redis-{{ version }}.tar.gz -C {{ root }}
    - watch:
      - file: download-redis-io

build-redis-io:
  cmd.wait:
    - cwd: {{ root }}/redis-{{ version }}
    - names:
      - make
      - make install
    - watch:
      - cmd: download-redis-io

redis-tools:
  pkg.installed:
    - require:
      - file: download-redis-io
