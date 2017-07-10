{%- from 'sun-java/settings.sls' import java with context %}

{%- if java.jce_url is defined %}

  {%- set zip_file = salt['file.join'](java.jre_lib_sec, 'UnlimitedJCEPolicy.zip') %}

include:
  - sun-java

sun-java-jce-unzip:
  pkg.installed:
    - name: unzip

download-jce-archive:
  cmd.run:
    - name: curl {{ java.dl_opts }} -o '{{ zip_file }}' '{{ java.jce_url }}'
    - creates: {{ zip_file }}
    - require:
      - archive: unpack-jdk-archive

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
    - onchanges:
      - cmd: download-jce-archive
    - require_in:
      - cmd: backup-non-jce-jar
      - cmd: unpack-jce-archive

  {%- endif %}

backup-non-jce-jar:
  cmd.run:
    - name: mv US_export_policy.jar US_export_policy.jar.nonjce; mv local_policy.jar local_policy.jar.nonjce;
    - cwd: {{ java.jre_lib_sec }}
    - creates: {{ java.jre_lib_sec ~ "/US_export_policy.jar.nonjce" }}

unpack-jce-archive:
  cmd.run:
    - name: unzip -j {{ zip_file }}
    - cwd: {{ java.jre_lib_sec }}
    - creates: {{ java.jre_lib_sec ~ "/US_export_policy.jar" }}
    - require:
      - pkg: unzip
      - cmd: download-jce-archive
      - cmd: backup-non-jce-jar

{%- endif %}
