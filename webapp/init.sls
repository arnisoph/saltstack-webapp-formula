#!jinja|yaml

{% from 'webapp/defaults.yaml' import rawmap_osfam with context %}
{% set datamap = salt['grains.filter_by'](rawmap_osfam, merge=salt['pillar.get']('webapp:lookup')) %}

include: {{ datamap.sls_include|default([]) }}
extend: {{ datamap.sls_extend|default({}) }}

{% set webapps = salt['pillar.get']('webapp:apps', {}) %}

{% for id, v in webapps|dictsort %}
webapp_{{ id }}_vcs_deployment:
  git:
    - latest
    - name: {{ v.vcs_source }}
    - rev: {{ v.vcs_rev }}
    - target: {{ v.vcs_target }}


webapp_{{ id }}_link_version_current:
  file:
    - symlink
    - name: {{ v.webroot }}/current
    - target: {{ v.webroot }}/{{ v.current_ver }}
    - makedirs: True
    - user: {{ v.user|default('root') }}
    - group: {{ v.group|default('root') }}

webapp_{{ id }}_file_recursive:
  file:
    - directory
    - name: {{ v.vcs_target }}
    - user: {{ v.user|default('root') }}
    - group: {{ v.group|default('root') }}
    - recurse:
      - user
      - group

{% endfor %}
