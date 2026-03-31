################################################################################
# {{ formatType(model_name) }} {{ formatType(model_type) }}
#
# Generated from {{ filename }} on {{ time }}.
################################################################################
{% if commands.items() %}
from util import entity_class_generator as ecg
from command import Command

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
    {{ id }}: ecg.create_entity_cls(
        Command,
        "{{ command.suite.component.instance_name }}",
        "{{ command.name }}",
        {% if command.type_model %}{{ command.type_package }}{% else %}None{% endif %},
        "{{ command.description|default('', true)|replace('\n', ' ')|replace('"', '\\"') }}",
        "Arg_Buffer"{{ "\n    " }}){{ "," if not loop.last }}
{% endfor %}
}
