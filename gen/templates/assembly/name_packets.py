################################################################################
# {{ formatType(model_name) }} {{ formatType(model_type) }}
#
# Generated from {{ filename }} on {{ time }}.
################################################################################
{% if packets.items() %}
from util.entity_class_generator import create_packet_cls

# Import packet types:
{% set imports = [] %}
{% for id, packet in packets.items() %}
{% if packet.type_model and packet.type_package not in imports %}
{% do imports.append(packet.type_package) %}
from {{ packet.type_package|lower }} import {{ packet.type_package }}
{% endif %}
{% endfor %}

# Packet ID constants:
{% for id, packet in packets.items() %}
{{ packet.full_name|replace(".","_") }} = {{ packet.id }}
{% endfor %}
{% endif %}

# Reverse lookup: ID to name string
packet_id_to_name = {
{% for id, packet in packets.items() %}
    {{ packet.id }}: "{{ packet.full_name }}"{{ "," if not loop.last }}
{% endfor %}
}

# Forward lookup: name string to ID
packet_name_to_id = {
{% for id, packet in packets.items() %}
    "{{ packet.full_name }}": {{ packet.id }}{{ "," if not loop.last }}
{% endfor %}
}

# ID to entity class mapping:
packet_id_cls_dict = {
{% for id, packet in packets.items() %}
{% set parts = packet.full_name.split('.') %}
    {{ id }}: create_packet_cls(
        "{{ parts[0] if parts|length > 1 else '' }}",
        "{{ parts[1] if parts|length > 1 else packet.name }}",
        {{ id }},
        {% if packet.type_model %}{{ packet.type_package }}{% else %}None{% endif %},
        "{{ packet.description|default('', true)|replace('\n', ' ')|replace('"', '\\"') }}"{{ "\n    " }}){{ "," if not loop.last }}
{% endfor %}
}
