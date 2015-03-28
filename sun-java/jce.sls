{%- from 'sun-java/settings.sls' import java with context %}

{%- if java.jce_url is defined %}

include:
  - sun-java

unzip:
  pkg.installed

download-jce-zip:
  cmd.run:
    - name: curl {{ java.dl_opts }} '{{ java.jce_url }}' > UnlimitedJCEPolicy.zip
    - cwd: {{ java.jre_lib_sec }}
    - unless: test -f {{ java.jre_lib_sec ~ "/UnlimitedJCEPolicy.zip" }}

backup-non-jce-jar:
  cmd.run:
    - name: mv US_export_policy.jar US_export_policy.jar.nonjce; mv local_policy.jar local_policy.jar.nonjce;
    - cwd: {{ java.jre_lib_sec }}
    - unless: test -f {{ java.jre_lib_sec ~ "/US_export_policy.jar.nonjce" }}

unpack-jce-zip:
  cmd.run:
    - name: unzip -j UnlimitedJCEPolicy.zip
    - cwd: {{ java.jre_lib_sec }}
    - unless: test -f {{ java.jre_lib_sec ~ "/US_export_policy.jar" }}
    - require:
      - pkg: unzip
      - cmd: download-jce-zip
      - cmd: backup-non-jce-jar

{%- endif %}
