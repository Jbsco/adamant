################################################################################
# {{ formatType(model_name) }} {{ formatType(model_type) }}
#
# Generated from {{ filename }} on {{ time }}.
################################################################################
from util import entity_class_generator as ecg

parameter_table_id_cls_dict = {
{% for path, sub in submodels.items() if sub.table_id is defined %}
    {{ sub.table_id }}: ecg.create_entity_cls(
        None,
        "{{ sub.parameters_instance_name }}",
        "{{ sub.name }}",
        None,
        "{{ sub.description|default('', true)|replace('"', '\\"') }}"{{ "\n    " }}){{ "," if not loop.last }}
{% endfor %}
}
