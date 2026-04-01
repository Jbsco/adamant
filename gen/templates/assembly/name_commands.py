################################################################################
# {{ formatType(model_name) }} {{ formatType(model_type) }}
#
# Generated from {{ filename }} on {{ time }}.
################################################################################
{% if commands.items() %}
from util.entity_class_generator import create_command_cls

# Import command argument types:
{% set imports = [] %}
{% for id, command in commands.items() %}
{% if command.type_model and command.type_package not in imports %}
{% do imports.append(command.type_package) %}
from {{ command.type_package|lower }} import {{ command.type_package }}
{% endif %}
{% endfor %}

# Command ID constants:
{% for id, command in commands.items() %}
{{ command.suite.component.instance_name }}_{{ command.name }} = {{ command.id }}
{% endfor %}
{% endif %}

# Reverse lookup: ID to name string
command_id_to_name = {
{% for id, command in commands.items() %}
    {{ command.id }}: "{{ command.suite.component.instance_name }}.{{ command.name }}"{{ "," if not loop.last }}
{% endfor %}
}

# Forward lookup: name string to ID
command_name_to_id = {
{% for id, command in commands.items() %}
    "{{ command.suite.component.instance_name }}.{{ command.name }}": {{ command.id }}{{ "," if not loop.last }}
{% endfor %}
}

# ID to entity class mapping:
command_id_cls_dict = {
{% for id, command in commands.items() %}
    {{ id }}: create_command_cls(
        "{{ command.suite.component.instance_name }}",
        "{{ command.name }}",
        {{ id }},
        {% if command.type_model %}{{ command.type_package }}{% else %}None{% endif %},
        "{{ command.description|default('', true)|replace('\n', ' ')|replace('"', '\\"') }}"{{ "\n    " }}){{ "," if not loop.last }}
{% endfor %}
}
