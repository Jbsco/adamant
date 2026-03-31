################################################################################
# {{ formatType(model_name) }} {{ formatType(model_type) }}
#
# Generated from {{ filename }} on {{ time }}.
################################################################################
from util import entity_class_generator as ecg
{% if parameters.items() %}

# Import parameter value types:
{% set imports = [] %}
{% for id, param in parameters.items() %}
{% if param.type_model and param.type_package not in imports %}
{% do imports.append(param.type_package) %}
from {{ param.type_package|lower }} import {{ param.type_package }}
{% endif %}
{% endfor %}
{% endif %}

parameter_id_cls_dict = {
{% for id, param in parameters.items() %}
    {{ id }}: ecg.create_entity_entry(
        "{{ param.suite.component.instance_name }}",
        "{{ param.name }}",
        {{ param.id }},
        {% if param.type_model %}{{ param.type_package }}{% else %}None{% endif %},
        "{{ param.description|default('', true)|replace('"', '\\"') }}"{{ "\n    " }}){{ "," if not loop.last }}
{% endfor %}
}
