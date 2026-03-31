################################################################################
# {{ formatType(model_name) }} {{ formatType(model_type) }}
#
# Generated from {{ filename }} on {{ time }}.
################################################################################
{% if faults.items() %}
from util import entity_class_generator as ecg
from fault import Fault

# Import fault parameter types:
{% set imports = [] %}
{% for id, fault in faults.items() %}
{% if fault.type_model and fault.type_package not in imports %}
{% do imports.append(fault.type_package) %}
from {{ fault.type_package|lower }} import {{ fault.type_package }}
{% endif %}
{% endfor %}
{% endif %}

fault_id_cls_dict = {
{% for id, fault in faults.items() %}
    {{ id }}: ecg.create_entity_cls(
        Fault,
        "{{ fault.suite.component.instance_name }}",
        "{{ fault.name }}",
        {% if fault.type_model %}{{ fault.type_package }}{% else %}None{% endif %},
        "{{ fault.description|default('', true)|replace('"', '\\"') }}"{{ "\n    " }}){{ "," if not loop.last }}
{% endfor %}
}
