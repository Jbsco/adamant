################################################################################
# {{ formatType(model_name) }} {{ formatType(model_type) }}
#
# Generated from {{ filename }} on {{ time }}.
################################################################################
{% if data_products.items() %}
from util.entity_class_generator import create_data_product_cls

# Import data product value types:
{% set imports = [] %}
{% for id, dp in data_products.items() %}
{% if dp.type_model and dp.type_package not in imports %}
{% do imports.append(dp.type_package) %}
from {{ dp.type_package|lower }} import {{ dp.type_package }}
{% endif %}
{% endfor %}

# Data product ID constants:
{% for id, dp in data_products.items() %}
{{ dp.suite.component.instance_name }}_{{ dp.name }} = {{ dp.id }}
{% endfor %}
{% endif %}

# Reverse lookup: ID to name string
data_product_id_to_name = {
{% for id, dp in data_products.items() %}
    {{ dp.id }}: "{{ dp.suite.component.instance_name }}.{{ dp.name }}"{{ "," if not loop.last }}
{% endfor %}
}

# Forward lookup: name string to ID
data_product_name_to_id = {
{% for id, dp in data_products.items() %}
    "{{ dp.suite.component.instance_name }}.{{ dp.name }}": {{ dp.id }}{{ "," if not loop.last }}
{% endfor %}
}

# ID to entity class mapping:
data_product_id_cls_dict = {
{% for id, dp in data_products.items() %}
    {{ id }}: create_data_product_cls(
        "{{ dp.suite.component.instance_name }}",
        "{{ dp.name }}",
        {{ id }},
        {% if dp.type_model %}{{ dp.type_package }}{% else %}None{% endif %},
        "{{ dp.description|default('', true)|replace('\n', ' ')|replace('"', '\\"') }}"{{ "\n    " }}){{ "," if not loop.last }}
{% endfor %}
}
