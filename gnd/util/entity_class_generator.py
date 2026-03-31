def create_entity_entry(component_instance_name, entity_name, entity_id, type_cls=None, description=""):
    """
    Creates a lightweight entity descriptor that carries structured metadata
    for a named, ID'd entity (command, data product, fault, packet, or parameter).

    This parallels event_class_generator.create_event_cls but without
    wire-format serialization — the autocoded packed types handle that.
    """

    class EntityEntry:
        __slots__ = ()

        @staticmethod
        def get_component():
            return component_instance_name

        @staticmethod
        def get_name():
            return entity_name

        @staticmethod
        def get_id():
            return entity_id

        @staticmethod
        def get_type_cls():
            return type_cls

        @staticmethod
        def get_description():
            return description

        @staticmethod
        def get_full_name():
            return component_instance_name + "." + entity_name

        def __repr__(self):
            return "%s.%s (0x%04X)" % (component_instance_name, entity_name, entity_id)

    return EntityEntry()
