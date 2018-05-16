{%- from 'sun-java/settings.sls' import java with context %}

{#- require a source_url - there is no default download location for a jdk #}

{%- if java.source_url is defined %}

  {%- set archive_file = salt['file.join'](java.prefix, salt['file.basename'](java.source_url)) %}

java-install-dir:
  file.directory:
    - name: {{ java.prefix }}
    - user: root
    - group: {{ java.group }}
    - mode: 755
    - makedirs: True

# curl fails (rc=23) if file exists (interrupte formula?)
# and test -f cannot detect corrupted archive
sun-java-remove-prev-archive:
  file.absent:
    - name: {{ archive_file }}
    - require:
      - file: java-install-dir

download-jdk-archive:
  cmd.run:
    - name: curl {{ java.dl_opts }} -o '{{ archive_file }}' '{{ java.source_url }}'
    - unless: test -f {{ java.java_realcmd }}
    - require:
      - file: sun-java-remove-prev-archive

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
    - onchanges:
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
      - file: remove-jdk-archive
    - onchanges:
      - cmd: download-jdk-archive
    - require:
      - module: check-jdk-archive

update-javahome-symlink:
  file.symlink:
    - name: {{ java.java_home }}
    - target: {{ java.java_real_home }}

remove-jdk-archive:
  file.absent:
    - name: {{ archive_file }}

{%- endif %}
