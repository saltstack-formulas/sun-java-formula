{%- from 'sun-java/settings.sls' import java with context %}

{%- if java.jce_url is defined %}

  {%- set zip_file = 'UnlimitedJCEPolicy.zip' -%}

include:
  - sun-java

unzip:
  pkg.installed

download-jce-zip:
  cmd.run:
    - name: curl {{ java.dl_opts }} -o '{{ zip_file }}' '{{ java.jce_url }}'
    - cwd: {{ java.jre_lib_sec }}
    - creates: {{ java.jre_lib_sec + '/' + zip_file }}
    - require:
      - archive: unpack-jdk-tarball

  {%- if java.jce_hash %}

check-sha256-hash:
  cmd.run:
    - name: sha256sum '{{ zip_file }}' | grep '^{{ java.jce_hash }} '
    - cwd: {{ java.jre_lib_sec }}
    - onchanges:
      - cmd: download-jce-zip
    - require_in:
      - cmd: backup-non-jce-jar
      - cmd: unpack-jce-zip

  {%- endif %}

backup-non-jce-jar:
  cmd.run:
    - name: mv US_export_policy.jar US_export_policy.jar.nonjce; mv local_policy.jar local_policy.jar.nonjce;
    - cwd: {{ java.jre_lib_sec }}
    - creates: {{ java.jre_lib_sec ~ "/US_export_policy.jar.nonjce" }}

unpack-jce-zip:
  cmd.run:
    - name: unzip -j {{ zip_file }}
    - cwd: {{ java.jre_lib_sec }}
    - creates: {{ java.jre_lib_sec ~ "/US_export_policy.jar" }}
    - require:
      - pkg: unzip
      - cmd: download-jce-zip
      - cmd: backup-non-jce-jar

{%- endif %}
