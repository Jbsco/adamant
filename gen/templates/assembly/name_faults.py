################################################################################
# {{ formatType(model_name) }} {{ formatType(model_type) }}
#
# Generated from {{ filename }} on {{ time }}.
################################################################################
{% if faults.items() %}
from util.entity_class_generator import create_fault_cls

# Import fault parameter types:
{% set imports = [] %}
{% for id, fault in faults.items() %}
{% if fault.type_model and fault.type_package not in imports %}
{% do imports.append(fault.type_package) %}
from {{ fault.type_package|lower }} import {{ fault.type_package }}
{% endif %}
{% endfor %}

# Fault ID constants:
{% for id, fault in faults.items() %}
{{ fault.suite.component.instance_name }}_{{ fault.name }} = {{ fault.id }}
{% endfor %}
{% endif %}

# Reverse lookup: ID to name string
fault_id_to_name = {
{% for id, fault in faults.items() %}
    {{ fault.id }}: "{{ fault.suite.component.instance_name }}.{{ fault.name }}"{{ "," if not loop.last }}
{% endfor %}
}

# Forward lookup: name string to ID
fault_name_to_id = {
{% for id, fault in faults.items() %}
    "{{ fault.suite.component.instance_name }}.{{ fault.name }}": {{ fault.id }}{{ "," if not loop.last }}
{% endfor %}
}

# ID to entity class mapping:
fault_id_cls_dict = {
{% for id, fault in faults.items() %}
    {{ id }}: create_fault_cls(
        "{{ fault.suite.component.instance_name }}",
        "{{ fault.name }}",
        {{ id }},
        {% if fault.type_model %}{{ fault.type_package }}{% else %}None{% endif %},
        "{{ fault.description|default('', true)|replace('\n', ' ')|replace('"', '\\"') }}"{{ "\n    " }}){{ "," if not loop.last }}
{% endfor %}
}
