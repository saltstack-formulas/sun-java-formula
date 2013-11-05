{%- set java_tgz       = salt['pillar.get']('java:tgz', 'jdk-linux-server-x64-1.7.0.45_22-bin.tar.gz') %}
{%- set tgz_path       = '/tmp/' + java_tgz %}
{%- set source         = salt['pillar.get']('java:source', '') %}
{%- set source_hash    = salt['pillar.get']('java:source_hash', '') %}
{%- set java_home      = salt['pillar.get']('java_home', '/usr/lib/java') %}
{%- set version_name   = salt['pillar.get']('java:version_name', 'jdk-linux-server-x64-1.7.0.45_22') %}
{%- set jprefix        = salt['pillar.get']('java:prefix', '/usr/share/java') %}
{%- set java_real_home = jprefix + '/' + version_name %}

{{ jprefix }}:
  file.directory:
    - user: root
    - group: root
    - mode: 755

{{ tgz_path }}:
  file.managed:
{%- if source %}
    - source: {{ source }}
    - source_hash: {{ source_hash }}
{%- else %}
    - source: salt://sun-java/files/{{ java_tgz }}
{%- endif %}

unpack-jdk-tarball:
  cmd.run:
    - name: tar xzf {{ tgz_path }}
    - cwd: {{ jprefix }}
    - unless: test -d {{ java_real_home }}
    - require:
      - file.directory: {{ jprefix }}
      - file.managed: {{ tgz_path }}
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

