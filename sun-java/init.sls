{%- from 'sun-java/settings.sls' import java with context %}

{#- require a source_url - there is no default download location for a jdk #}

{%- if java.source_url is defined %}

  {%- set archive_file = salt['file.join'](java.tmpdir, salt['file.basename'](java.source_url)) %}

java-install-dir:
  file.directory:
    - names:
      - {{ java.prefix }}
      - {{ java.tmpdir }}
    - user: root
    - group: {{ java.group }}
    - mode: 755
    - makedirs: True

download-jdk-archive:
  cmd.run:
    - name: curl {{ java.dl_opts }} -o '{{ archive_file }}' '{{ java.source_url }}'
    - unless: test -f {{ archive_file }}
    - require:
      - file: java-install-dir
    {% if grains['saltversioninfo'] >= [2017, 7, 0] %}
    - retry:
        attempts: 3
        interval: 60
        until: True
        splay: 10
    {% endif %}

  {%- if java.source_hash %}

# FIXME: We need to check hash sum separately, because
# ``archive.extracted`` state does not support integrity verification
# for local archives prior to and including Salt release 2016.11.6.
#
# See: https://github.com/saltstack/salt/pull/41914

check-jdk-archive:
  module.run:
    - name: file.check_hash
    - path: {{ archive_file }}
    - file_hash: {{ java.source_hash }}
    - require:
      - cmd: download-jdk-archive
    - require_in:
      - archive: unpack-jdk-archive

  {%- endif %}

unpack-jdk-archive:
  {% if grains.os == 'MacOS' %}
  macpackage.installed:
    - name: '{{ archive_file }}'
    - store: False
    - dmg: True
    - app: False
    - force: True
    - allow_untrusted: True
    - require_in:
  {% else %}
  archive.extracted:
    - name: {{ java.prefix }}
    - source: file://{{ archive_file }}
    - archive_format: {{ java.archive_type }}
    - user: root
    - group: {{ java.group }}
    - unless: test "`uname`" = "Darwin"
    - if_missing: {{ java.java_realcmd }}
    - require_in:
      - file: update-javahome-symlink
  {% endif %}
    - require:
      - cmd: download-jdk-archive

update-javahome-symlink:
  file.symlink:
    - name: {{ java.java_home }}
    - target: {{ java.java_real_home }}
    - force: True

{%- endif %}
