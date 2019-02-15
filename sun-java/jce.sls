{%- from 'sun-java/settings.sls' import java with context %}

{%- if java.jce_url is defined %}

  {%- set zip_file = salt['file.join'](java.jre_lib_sec, 'UnlimitedJCEPolicy.zip') %}
  {%- set us_policy_jar = salt['file.join'](java.jre_lib_sec, 'US_export_policy.jar') %}
  {%- set local_policy_jar = salt['file.join'](java.jre_lib_sec, 'local_policy.jar') %}

include:
  - sun-java

sun-java-jce-unzip:
  pkg.installed:
    - name: unzip

download-jce-archive:
  file.directory:
    - name: {{ java.jre_lib_sec }}
    - makedirs: True
  cmd.run:
    - name: curl {{ java.dl_opts }} -o '{{ zip_file }}' '{{ java.jce_url }}'
    - unless: test -f {{ zip_file }}
    - creates: {{ zip_file }}
    - onlyif: >
        test ! -f {{ us_policy_jar }} ||
        test ! -f {{ us_policy_jar }}.nonjce
    - require:
      - file: download-jce-archive
    {% if grains['saltversioninfo'] >= [2017, 7, 0] %}
    - retry:
        attempts: 3
        interval: 60
        until: True
        splay: 10
    {% endif %}

# FIXME: use ``archive.extracted`` state.
# Be aware that it does not support integrity verification
# for local archives prior to and including Salt release 2016.11.6.
#
# See: https://github.com/saltstack/salt/pull/41914

  {%- if java.jce_hash %}

check-jce-archive:
  module.run:
    - name: file.check_hash
    - path: {{ zip_file }}
    - file_hash: {{ java.jce_hash }}
    - require:
      - cmd: download-jce-archive
    - require_in:
      - cmd: backup-non-jce-jar
      - cmd: unpack-jce-archive

  {%- endif %}

backup-non-jce-jar:
  cmd.run:
    - name:
      - mv {{ us_policy_jar }} {{ us_policy_jar }}.nonjce
      - mv {{ local_policy_jar }} {{ local_policy_jar }}.nonjce
    - onlyif:
      - test -f {{ us_policy_jar }}
      - test -f {{ local_policy_jar }}
    - require:
      - cmd: download-jce-archive

unpack-jce-archive:
  cmd.run:
    - name: unzip -j -o {{ zip_file }}
    - cwd: {{ java.jre_lib_sec }}
    - creates:
      - {{ us_policy_jar }}
      - {{ local_policy_jar }}
    - require:
      - pkg: unzip
      - cmd: download-jce-archive
      - cmd: backup-non-jce-jar

{%- endif %}
