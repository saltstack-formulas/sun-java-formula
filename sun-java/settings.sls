{% set p  = salt['pillar.get']('java', {}) %}
{% set g  = salt['grains.get']('java', {}) %}

{%- set release              = '8' %}
{%- set major                = '0' %}
{%- set minor                = '181' %}
{%- set build                = '-b13' %}
{%- set dirhash              = '/96a7b8442fe848ef90c96a2fad6ed6d1/jdk-' %}

{# See Oracle Java SE checksums page here: https://www.oracle.com/webfolder/s/digest/8u181checksum.html #}
{%- set default_jce_hash = 'sha256=f3020a3922efd6626c2fff45695d527f34a8020e938a49292561f18ad1320b59' %}

{%- set default_version_name = 'jdk1.' + release + '.' + major + '_' + minor %}
{%- set version_name         = g.get('version_name', p.get('version_name', default_version_name)) %}

{% if grains.os == 'MacOS' %}
  {% set archive = '-macosx-x64.dmg' %}
  {% set default_source_hash = 'sha256=3ea78e0107f855b47a55414fadaabd04b94e406050d615663d54200ec85efc9b' %}
  {% set group = 'wheel' %}
  {% set archive_type = g.get('archive_type', p.get('archive_type', 'dmg' )) %}
  {% set java_home = salt['grains.get']('java_home', salt['pillar.get']('java_home', '/usr/local/lib/java')) %}
  {% set prefix    = g.get('prefix', p.get('prefix', '/Library/Java/JavaVirtualMachines')) %}
  {% set default_symlink = '/usr/local/bin/java' %}
  {% set java_real_home = g.get('java_real_home', p.get('java_real_home', prefix + '/' + version_name + '.jdk/Contents/Home' )) %}
{% else %}
  {%- set archive = '-linux-x64.tar.gz' %}
  {%- set default_source_hash = 'sha256=1845567095bfbfebd42ed0d09397939796d05456290fb20a83c476ba09f991d3' %}
  {%- set group = 'root' %}
  {%- set archive_type = g.get('archive_type', p.get('archive_type', 'tar' )) %}
  {%- set java_home = salt['grains.get']('java_home', salt['pillar.get']('java_home', '/usr/lib/java')) %}
  {%- set prefix    = g.get('prefix', p.get('prefix', '/usr/share/java')) %}
  {%- set default_symlink = '/usr/bin/java' %}
  {%- set java_real_home  = g.get('java_real_home', p.get('java_real_home', prefix + '/' + version_name )) %}
{% endif %}

{%- set uri = 'http://download.oracle.com/otn-pub/java/' %}
{%- set default_source_url = uri + 'jdk/' + release + 'u' + minor + build + dirhash + release + 'u' + minor + archive %}
{%- set default_jce_url    = uri + 'jce/' + release + '/jce_policy-' + release + '.zip' %}
{%- set default_dl_opts      = '-b oraclelicense=accept-securebackup-cookie -L -s' %}

{%- set source_url           = g.get('source_url', p.get('source_url', default_source_url)) %}

{%- if source_url == default_source_url %}
  {%- set source_hash        = default_source_hash %}
{%- else %}
  {%- set source_hash        = g.get('source_hash', p.get('source_hash', default_source_hash )) %}
{%- endif %}

{%- set jce_url              = g.get('jce_url', p.get('jce_url', default_jce_url)) %}

{%- if jce_url == default_jce_url %}
  {%- set jce_hash           = default_jce_hash %}
{%- else %}
  {%- set jce_hash           = g.get('jce_hash', p.get('jce_hash', default_jce_hash )) %}
{%- endif %}

{%- set dl_opts              = g.get('dl_opts', p.get('dl_opts', default_dl_opts)) %}
{%- set jre_lib_sec          = g.get('jre_lib_sec', p.get('jre_lib_sec', java_real_home + '/jre/lib/security' )) %}
{%- set java_symlink         = g.get('java_symlink', p.get('java_symlink', default_symlink )) %}
{%- set java_realcmd         = g.get('realcmd', p.get('realcmd', java_real_home + '/bin/java' )) %}
{%- set javac_symlink        = java_symlink + 'c' %}
{%- set javac_realcmd        = java_realcmd + 'c' %}
{%- set alt_priority         = g.get('alt_priority', p.get('alt_priority', None)) %}

{%- set java = {} %}
{%- do java.update( { 'version_name'   : version_name,
                      'source_url'     : source_url,
                      'source_hash'    : source_hash,
                      'jce_url'        : jce_url,
                      'jce_hash'       : jce_hash,
                      'dl_opts'        : dl_opts,
                      'java_home'      : java_home,
                      'prefix'         : prefix,
                      'group'          : group,
                      'java_real_home' : java_real_home,
                      'jre_lib_sec'    : jre_lib_sec,
                      'archive_type'   : archive_type,
                      'java_symlink'   : java_symlink,
                      'java_realcmd'   : java_realcmd,
                      'javac_symlink'  : javac_symlink,
                      'javac_realcmd'  : javac_realcmd,
                      'alt_priority'   : alt_priority,
                    } ) %}
