################################################################################
# {{ formatType(model_name) }} {{ formatType(model_type) }}
#
# Generated from {{ filename }} on {{ time }}.
################################################################################
from util import entity_class_generator as ecg
{% if commands.items() %}

# Import command argument types:
{% set imports = [] %}
{% for id, command in commands.items() %}
{% if command.type_model and command.type_package not in imports %}
{% do imports.append(command.type_package) %}
from {{ command.type_package|lower }} import {{ command.type_package }}
{% endif %}
{% endfor %}
{% endif %}

command_id_cls_dict = {
{% for id, command in commands.items() %}
    {{ id }}: ecg.create_entity_entry(
        "{{ command.suite.component.instance_name }}",
        "{{ command.name }}",
        {{ command.id }},
        {% if command.type_model %}{{ command.type_package }}{% else %}None{% endif %},
        "{{ command.description|default('', true)|replace('"', '\\"') }}"{{ "\n    " }}){{ "," if not loop.last }}
{% endfor %}
}
