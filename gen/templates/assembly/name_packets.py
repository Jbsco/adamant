################################################################################
# {{ formatType(model_name) }} {{ formatType(model_type) }}
#
# Generated from {{ filename }} on {{ time }}.
################################################################################
{% if packets.items() %}
from util import entity_class_generator as ecg
from packet import Packet

# Import packet types:
{% set imports = [] %}
{% for id, packet in packets.items() %}
{% if packet.type_model and packet.type_package not in imports %}
{% do imports.append(packet.type_package) %}
from {{ packet.type_package|lower }} import {{ packet.type_package }}
{% endif %}
{% endfor %}
{% endif %}

packet_id_cls_dict = {
{% for id, packet in packets.items() %}
{% set parts = packet.full_name.split('.') %}
    {{ id }}: ecg.create_entity_cls(
        Packet,
        "{{ parts[0] if parts|length > 1 else '' }}",
        "{{ parts[1] if parts|length > 1 else packet.name }}",
        {% if packet.type_model %}{{ packet.type_package }}{% else %}None{% endif %},
        "{{ packet.description|default('', true)|replace('"', '\\"') }}",
        "Buffer"{{ "\n    " }}){{ "," if not loop.last }}
{% endfor %}
}
