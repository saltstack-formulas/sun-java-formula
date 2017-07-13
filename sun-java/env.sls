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

# Add javahome to alternatives
javahome-alt-install:
  alternatives.install:
    - name: java-home
    - link: {{ java.java_home }}
    - path: {{ java.java_real_home }}
    - priority: {{ java.alts_priority }}

# ensure javahome alternative
javahome-alt-set:
  alternatives.set:
  - name: java-home
  - path: {{ java.java_real_home }}
  - require:
    - javahome-alt-install

# Add java to alternatives
java-alt-install:
  alternatives.install:
    - name: java
    - link: {{ java.java_symlink }}
    - path: {{ java.java_realcmd }}
    - priority: {{ java.alts_priority }}
    - require:
      - javahome-alt-set

# ensure java alternative
java-alt-set:
  alternatives.set:
  - name: java
  - path: {{ java.java_realcmd }}
  - require:
    - java-alt-install

# Add javac to alternatives
javac-alt-install:
  alternatives.install:
    - name: javac
    - link: {{ java.javac_symlink }}
    - path: {{ java.javac_realcmd }}
    - priority: {{ java.alts_priority }}
    - require:
      - java-alt-set

# ensure javac alternative
javac-alt-set:
  alternatives.set:
  - name: javac
  - path: {{ java.javac_realcmd }}
  - require:
    - javac-alt-install
