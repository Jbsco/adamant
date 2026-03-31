################################################################################
# {{ formatType(model_name) }} {{ formatType(model_type) }}
#
# Generated from {{ filename }} on {{ time }}.
################################################################################
from util import entity_class_generator as ecg
{% if data_products.items() %}

# Import data product value types:
{% set imports = [] %}
{% for id, dp in data_products.items() %}
{% if dp.type_model and dp.type_package not in imports %}
{% do imports.append(dp.type_package) %}
from {{ dp.type_package|lower }} import {{ dp.type_package }}
{% endif %}
{% endfor %}
{% endif %}

data_product_id_cls_dict = {
{% for id, dp in data_products.items() %}
    {{ id }}: ecg.create_entity_entry(
        "{{ dp.suite.component.instance_name }}",
        "{{ dp.name }}",
        {{ dp.id }},
        {% if dp.type_model %}{{ dp.type_package }}{% else %}None{% endif %},
        "{{ dp.description|default('', true)|replace('"', '\\"') }}"{{ "\n    " }}){{ "," if not loop.last }}
{% endfor %}
}
