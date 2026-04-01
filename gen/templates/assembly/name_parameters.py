################################################################################
# {{ formatType(model_name) }} {{ formatType(model_type) }}
#
# Generated from {{ filename }} on {{ time }}.
################################################################################
{% if parameters.items() %}
from util.entity_class_generator import create_parameter_cls

# Import parameter value types:
{% set imports = [] %}
{% for id, param in parameters.items() %}
{% if param.type_model and param.type_package not in imports %}
{% do imports.append(param.type_package) %}
from {{ param.type_package|lower }} import {{ param.type_package }}
{% endif %}
{% endfor %}

# Parameter ID constants:
{% for id, param in parameters.items() %}
{{ param.suite.component.instance_name }}_{{ param.name }} = {{ param.id }}
{% endfor %}
{% endif %}

# Reverse lookup: ID to name string
parameter_id_to_name = {
{% for id, param in parameters.items() %}
    {{ param.id }}: "{{ param.suite.component.instance_name }}.{{ param.name }}"{{ "," if not loop.last }}
{% endfor %}
}

# Forward lookup: name string to ID
parameter_name_to_id = {
{% for id, param in parameters.items() %}
    "{{ param.suite.component.instance_name }}.{{ param.name }}": {{ param.id }}{{ "," if not loop.last }}
{% endfor %}
}

# ID to entity class mapping:
parameter_id_cls_dict = {
{% for id, param in parameters.items() %}
    {{ id }}: create_parameter_cls(
        "{{ param.suite.component.instance_name }}",
        "{{ param.name }}",
        {{ id }},
        {% if param.type_model %}{{ param.type_package }}{% else %}None{% endif %},
        "{{ param.description|default('', true)|replace('\n', ' ')|replace('"', '\\"') }}"{{ "\n    " }}){{ "," if not loop.last }}
{% endfor %}
}
