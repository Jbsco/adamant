################################################################################
# {{ formatType(model_name) }} {{ formatType(model_type) }}
#
# Generated from {{ filename }} on {{ time }}.
################################################################################
{% set ns = namespace(has_tables=false) %}
{% for path, sub in submodels.items() if sub.table_id is defined and sub.table_id is not none %}
{% set ns.has_tables = true %}
{% endfor %}
{% if ns.has_tables %}
from util import entity_class_generator as ecg

# Parameter table ID constants:
{% for path, sub in submodels.items() if sub.table_id is defined and sub.table_id is not none %}
{{ sub.name }} = {{ sub.table_id }}
{% endfor %}
{% endif %}

# Reverse lookup: ID to name string
parameter_table_id_to_name = {
{% for path, sub in submodels.items() if sub.table_id is defined and sub.table_id is not none %}
    {{ sub.table_id }}: "{{ sub.name }}"{{ "," if not loop.last }}
{% endfor %}
}

# Forward lookup: name string to ID
parameter_table_name_to_id = {
{% for path, sub in submodels.items() if sub.table_id is defined and sub.table_id is not none %}
    "{{ sub.name }}": {{ sub.table_id }}{{ "," if not loop.last }}
{% endfor %}
}

# ID to entity class mapping:
parameter_table_id_cls_dict = {
{% for path, sub in submodels.items() if sub.table_id is defined and sub.table_id is not none %}
    {{ sub.table_id }}: ecg.create_entity_cls(
        None,
        "{{ sub.parameters_instance_name }}",
        "{{ sub.name }}",
        None,
        "{{ sub.description|default('', true)|replace('"', '\\"') }}"{{ "\n    " }}){{ "," if not loop.last }}
{% endfor %}
}
