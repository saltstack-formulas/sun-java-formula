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

  {%- if java.source_hash %}

# FIXME: We need to check hash sum separately, because
# ``archive.extracted`` state does not support integrity verification
# for local archives prior to and including Salt release 2016.11.6.
#
# See: https://github.com/saltstack/salt/pull/41914

check-jdk-tarball:
  module.run:
    - name: file.check_hash
    - path: {{ tarball_file }}
    - file_hash: {{ java.source_hash }}
    - onchanges:
      - download-jdk-tarball
    - require_in:
      - archive: unpack-jdk-tarball

  {%- endif %}

unpack-jdk-tarball:
  archive.extracted:
    - name: {{ java.prefix }}
    - source: file://{{ tarball_file }}
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
