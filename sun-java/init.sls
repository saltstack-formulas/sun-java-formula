{%- from 'sun-java/settings.sls' import java with context %}

{#- require a source_url - there is no default download location for a jdk #}

{%- if java.source_url is defined %}

  {%- set tarball_file = java.prefix + '/' + java.source_url.split('/') | last %}

java-install-dir:
  file.directory:
    - name: {{ java.prefix }}
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

download-jdk-tarball:
  cmd.run:
    - name: curl {{ java.dl_opts }} -o '{{ tarball_file }}' '{{ java.source_url }}'
    - unless: test -d {{ java.java_real_home }} || test -f {{ tarball_file }}
    - require:
      - file: java-install-dir

unpack-jdk-tarball:
  archive.extracted:
    - name: {{ java.prefix }}
    - source: file://{{ tarball_file }}
    {%- if java.source_hash %}
    - source_hash: sha256={{ java.source_hash }}
    {%- endif %}
    - archive_format: tar
    - user: root
    - group: root
    - if_missing: {{ java.java_real_home }}
    - onchanges:
      - cmd: download-jdk-tarball

create-java-home:
  alternatives.install:
    - name: java-home
    - link: {{ java.java_home }}
    - path: {{ java.java_real_home }}
    - priority: 30
    - onlyif: test -d {{ java.java_real_home }} && test ! -L {{ java.java_home }}
    - require:
      - archive: unpack-jdk-tarball

update-java-home-symlink:
  file.symlink:
    - name: {{ java.java_home }}
    - target: {{ java.java_real_home }}

remove-jdk-tarball:
  file.absent:
    - name: {{ tarball_file }}

{%- endif %}
