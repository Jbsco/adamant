def create_entity_cls(
    base_cls,
    component_instance_name,
    entity_name,
    param_type_cls,
    description="",
    buffer_field="Param_Buffer",
):
    """
    Generic class factory for Adamant ID'd entities. Creates a subclass of
    base_cls (Event, Data_Product, Packet, Fault, etc.) that:

      - Accepts a typed Param/Buffer kwarg and serializes it into the base
        class's buffer field on construction
      - Decodes the buffer back into the typed parameter on deserialization
      - Pretty-prints with timestamp, component, name, ID, and decoded param

    Parameters:
      base_cls                 - The autocoded packed type base (e.g. Event, Data_Product)
      component_instance_name  - Assembly component instance name
      entity_name              - Entity name within the component
      param_type_cls           - Packed type class for the payload, or None
      description              - Human-readable description string
      buffer_field             - Name of the buffer field on base_cls
                                 ("Param_Buffer" for Event/Fault, "Buffer" for Data_Product/Packet)
    """

    # When no base class is provided (e.g. parameters), return a
    # lightweight metadata-only descriptor instead of a packed type subclass.
    if base_cls is None:
        class EntityEntry:
            __slots__ = ()
            component_instance_name = component_instance_name
            entity_name = entity_name
            description = description
            param_type_cls = param_type_cls

            def __repr__(self):
                return "%s.%s" % (component_instance_name, entity_name)

        return EntityEntry

    class SpecificEntity(base_cls):
        def __init__(self, Header=None, Param=None):
            self.component_instance_name = component_instance_name
            self.entity_name = entity_name
            self.description = description
            self.has_param = False
            param_buffer = None
            if Param is not None:
                self.has_param = True
                if param_type_cls is not None:
                    assert isinstance(Param, param_type_cls), (
                        "Expected type for field 'param' to be '"
                        + str(param_type_cls)
                        + "' and instead found '"
                        + str(type(Param))
                    )
                param_buffer = list(Param.to_byte_array())
            self.Param = Param

            super(SpecificEntity, self).__init__(
                Header=Header, **{buffer_field: param_buffer}
            )

        def _from_byte_array(self, stream):
            super(SpecificEntity, self)._from_byte_array(stream)
            buf = getattr(self, buffer_field, None)
            if buf and param_type_cls is not None:
                self.Param = param_type_cls.create_from_byte_array(bytes(buf))

        def pretty_print_string(self):
            seconds = 0
            subseconds = 0
            id = 0
            param = ""
            if self.Header:
                if self.Header.Time:
                    if self.Header.Time.Seconds:
                        seconds = self.Header.Time.Seconds
                    if self.Header.Time.Subseconds:
                        subseconds = self.Header.Time.Subseconds
                if self.Header.Id:
                    id = self.Header.Id
            if self.Param:
                param = ": " + self.Param.to_tuple_string()

            if self.Header.Time._size_in_bytes == 6:
                return "%010d.%06d - %s.%s (0x%04X) %s" % (
                    seconds,
                    int((subseconds / (2**16)) * 1000000),
                    self.component_instance_name,
                    self.entity_name,
                    id,
                    param,
                )
            else:
                return "%010d.%09d - %s.%s (0x%04X) %s" % (
                    seconds,
                    int((subseconds / (2**32)) * 1000000000),
                    self.component_instance_name,
                    self.entity_name,
                    id,
                    param,
                )

    return SpecificEntity
