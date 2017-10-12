{%- from 'sun-java/settings.sls' import java with context %}

jdk-config:
  file.managed:
    - name: /etc/profile.d/java.sh
    - source: salt://sun-java/java.sh
    - template: jinja
    - mode: 644
    - user: root
    - group: root
    - context:
      java_home: {{ java.java_home }}

javahome-link:
  file.symlink:
    - name: {{ java.java_home }}
    - target: {{ java.java_real_home }}

java-link:
  file.symlink:
    - name: {{ java.java_symlink }}
    - target: {{ java.java_realcmd }}
    - require:
      - file: javahome-link

javac-link:
  file.symlink:
    - name: {{ java.javac_symlink }}
    - target: {{ java.javac_realcmd }}
    - onlyif: test -f {{ java.javac_realcmd }}
    - require:
      - file: java-link

