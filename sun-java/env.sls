{%- from 'sun-java/settings.sls' import java with context %}

{% if grains.os not in ('Windows',) %}

jdk-config:
  file.managed:
    - name: /etc/profile.d/java.sh
    - source: salt://sun-java/java.sh
    - template: jinja
    - mode: 644
    - user: root
    - group: {{ java.group }}
    - context:
      java_home: {{ java.java_home }}

  {% if java.alt_priority is none %}

javahome-link:
  file.symlink:
    - name: {{ java.java_home }}
    - target: {{ java.java_real_home }}

java-link:
  file.symlink:
    - name: {{ java.java_symlink }}
    - target: {{ java.java_realcmd }}
    - onlyif: test -f {{ java.java_realcmd }}
    - force: true
    - require:
      - file: javahome-link

javac-link:
  file.symlink:
    - name: {{ java.javac_symlink }}
    - target: {{ java.javac_realcmd }}
    - onlyif: test -f {{ java.javac_realcmd }}
    - force: true
    - require:
      - file: java-link

  {% elif grains.os_family not in ('Arch', 'MacOS') %}

# Add javahome to alternatives
javahome-alt-install:
  alternatives.install:
    - name: java-home
    - link: {{ java.java_home }}
    - path: {{ java.java_real_home }}
    - priority: {{ java.alt_priority }}

# ensure javahome alternative
javahome-alt-set:
  alternatives.set:
    - name: java-home
    - path: {{ java.java_real_home }}
    - require:
      - alternatives: javahome-alt-install

# Add java to alternatives
java-alt-install:
  alternatives.install:
    - name: java
    - link: {{ java.java_symlink }}
    - path: {{ java.java_realcmd }}
    - priority: {{ java.alt_priority }}
    - require:
      - alternatives: javahome-alt-set

# ensure java alternative
java-alt-set:
  alternatives.set:
    - name: java
    - path: {{ java.java_realcmd }}
    - require:
      - alternatives: java-alt-install

# Add javac to alternatives if found
javac-alt-install:
  alternatives.install:
    - name: javac
    - link: {{ java.javac_symlink }}
    - path: {{ java.javac_realcmd }}
    - priority: {{ java.alt_priority }}
    - require:
      - alternatives: java-alt-set
    - onlyif: test -f {{ java.javac_realcmd }}

# ensure javac alternative if found
javac-alt-set:
  alternatives.set:
    - name: javac
    - path: {{ java.javac_realcmd }}
    - require:
      - alternatives: javac-alt-install
    - onlyif: test -f {{ java.javac_realcmd }}

  {% endif %}

{% endif %}

