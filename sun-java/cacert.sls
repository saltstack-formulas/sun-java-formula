{%- from 'sun-java/settings.sls' import java with context %}
{# only run if pillars defined #}
{%- if salt.pillar.get('java:cacert') %}
{%- for ca in salt['pillar.fetch']('java:cacert', default=[] ) %}

{# download certificate only if not already in store #}
get-{{ca.alias}}:
  file.managed:
    - name: /tmp/{{ca.alias}}.tmp
    - source: {{ca.source}}
    {%- if ca.source_hash is defined %}
    - source_hash: {{ca.source_hash}}
    {%- else %}
    - skip_verify: True
    {%- endif %}
    - unless: '{{java.keytool_cmd}} -list -keystore {{java.cacert_keystore}} -storepass {{java.cacert_keystore_password}} | grep -qi {{ca.fingeprint}}'
    - require_in:
      -file: delete-{{ca.alias}}
{# deploy certificate if downloaded #}
deploy-{{ca.alias}}:
  cmd.run:
    - name: '{{java.keytool_cmd}} -importcert -alias {{ca.alias}} -keystore {{java.cacert_keystore}} -storepass {{java.cacert_keystore_password}} -noprompt -trustcacerts -file /tmp/{{ca.alias}}.tmp'
    - onchanges:
      - file: get-{{ca.alias}}

{# cleanup if deployed #}
delete-{{ca.alias}}:
  file.absent:
    - name: /tmp/{{ca.alias}}.tmp

{%- endfor %}
{%- endif %}
