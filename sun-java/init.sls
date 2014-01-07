# the version_name has to be the top-level directory name inside the tarball
{%- set pillar_version_name   = salt['pillar.get']('java:version_name', 'jdk1.7.0_45') %}
{%- set pillar_source_url     = salt['pillar.get']('java:source_url', '') %}
{%- set pillar_dl_opts        = salt['pillar.get']('java:dl_opts', '-L') %}
{%- set version_name   = salt['grains.get']('java:version_name', pillar_version_name) %}
{%- set source_url     = salt['grains.get']('java:source_url', pillar_source_url) %}
{%- set dl_opts        = salt['grains.get']('java:dl_opts', pillar_dl_opts) %}

# require a source_url - there is no default download location for a jdk
{%- if source_url is defined %}

{%- set java_home      = salt['pillar.get']('java_home', '/usr/lib/java') %}
{%- set jprefix        = salt['pillar.get']('java:prefix', '/usr/share/java') %}
{%- set java_real_home = jprefix + '/' + version_name %}

{{ jprefix }}:
  file.directory:
    - user: root
    - group: root
    - mode: 755

unpack-jdk-tarball:
  cmd.run:
    - name: curl {{ dl_opts }} '{{ source_url }}' | tar xz
    - cwd: {{ jprefix }}
    - unless: test -d {{ java_real_home }}
    - require:
      - file.directory: {{ jprefix }}
  alternatives.install:
    - name: java-home-link
    - link: {{ java_home }}
    - path: {{ java_real_home }}
    - priority: 30
    - require:
      - file.directory: {{ jprefix }}

jdk-config:
  file.managed:
    - name: /etc/profile.d/java.sh
    - source: salt://sun-java/java.sh.jinja
    - template: jinja
    - mode: 644
    - user: root
    - group: root
    - context:
      java_home: {{ java_home }}

{%- endif %}