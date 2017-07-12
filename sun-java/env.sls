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
    - priority: 301800111
    - require:
      - update-javahome-symlink

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
    - priority: 301800111
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
    - priority: 301800111
    - require:
      - java-alt-set

# ensure javac alternative
javac-alt-set:
  alternatives.set:
  - name: javac
  - path: {{ java.javac_realcmd }}
  - require:
    - javac-alt-install

# source PATH with our JAVA_HOME
java-source-file:
  cmd.run:
  - name: source /etc/profile
  - cwd: /root
  - require:
    - java-alt-set

