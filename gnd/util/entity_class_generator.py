def _create_entity_cls(
    base_cls,
    component_instance_name,
    entity_name,
    entity_id,
    param_type_cls,
    description="",
    buffer_field="Param_Buffer",
    buffer_length_field="Param_Buffer_Length",
    header_cls=None,
    build_header=None,
):
    """
    Internal class factory for Adamant ID'd entities. Creates a subclass of
    base_cls that serializes/deserializes a typed payload and pretty-prints
    with timestamp, component, name, ID, and decoded param.

    Use the entity-specific public functions below instead of calling this
    directly.

    Parameters:
      base_cls                 - The autocoded packed type base (e.g. Event, Data_Product)
      component_instance_name  - Assembly component instance name
      entity_name              - Entity name within the component
      entity_id                - Numeric ID assigned in the assembly
      param_type_cls           - Packed type class for the payload, or None
      description              - Human-readable description string
      buffer_field             - Name of the buffer field on base_cls
      buffer_length_field      - Name of the buffer length field on the header
      header_cls               - Header class to auto-construct
      build_header             - Callable(entity_id, param_size, Time) -> Header,
                                 used when Header is not explicitly provided
    """

    # When no base class is provided (e.g. parameters), return a
    # lightweight metadata-only descriptor instead of a packed type subclass.
    if base_cls is None:
        _cin = component_instance_name
        _en = entity_name
        _eid = entity_id
        _desc = description
        _ptc = param_type_cls

        class EntityEntry:
            __slots__ = ()
            component_instance_name = _cin
            entity_name = _en
            id = _eid
            description = _desc
            param_type_cls = _ptc

            def __repr__(self):
                return "%s.%s" % (_cin, _en)

        return EntityEntry

    class SpecificEntity(base_cls):
        id = entity_id

        def __init__(self, Header=None, Param=None, Time=None):
            self.component_instance_name = component_instance_name
            self.entity_name = entity_name
            self.description = description
            self.has_param = False
            param_buffer = None
            param_size = 0
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
                param_size = len(param_buffer)
            self.Param = Param

            # Auto-construct header when not provided explicitly:
            if Header is None and build_header is not None:
                Header = build_header(entity_id, param_size, Time)

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

            if not self.Header or not self.Header.Time or self.Header.Time._size_in_bytes == 6:
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


# -----------------------------------------------------------------------
# Entity-specific public factories
# -----------------------------------------------------------------------

def create_event_cls(component_instance_name, entity_name, entity_id, param_type_cls, description=""):
    from event import Event
    from event_header import Event_Header

    def _build_header(eid, param_size, time):
        return Event_Header(Time=time, Id=eid, Param_Buffer_Length=param_size)

    return _create_entity_cls(
        Event, component_instance_name, entity_name, entity_id, param_type_cls, description,
        buffer_field="Param_Buffer",
        buffer_length_field="Param_Buffer_Length",
        header_cls=Event_Header,
        build_header=_build_header,
    )


def create_command_cls(component_instance_name, entity_name, entity_id, param_type_cls, description=""):
    from command import Command
    from command_header import Command_Header

    def _build_header(eid, param_size, time):
        return Command_Header(Id=eid, Arg_Buffer_Length=param_size)

    return _create_entity_cls(
        Command, component_instance_name, entity_name, entity_id, param_type_cls, description,
        buffer_field="Arg_Buffer",
        buffer_length_field="Arg_Buffer_Length",
        header_cls=Command_Header,
        build_header=_build_header,
    )


def create_data_product_cls(component_instance_name, entity_name, entity_id, param_type_cls, description=""):
    from data_product import Data_Product
    from data_product_header import Data_Product_Header

    def _build_header(eid, param_size, time):
        return Data_Product_Header(Time=time, Id=eid, Buffer_Length=param_size)

    return _create_entity_cls(
        Data_Product, component_instance_name, entity_name, entity_id, param_type_cls, description,
        buffer_field="Buffer",
        buffer_length_field="Buffer_Length",
        header_cls=Data_Product_Header,
        build_header=_build_header,
    )


def create_packet_cls(component_instance_name, entity_name, entity_id, param_type_cls, description=""):
    from packet import Packet
    from packet_header import Packet_Header

    def _build_header(eid, param_size, time):
        return Packet_Header(Time=time, Id=eid, Buffer_Length=param_size)

    return _create_entity_cls(
        Packet, component_instance_name, entity_name, entity_id, param_type_cls, description,
        buffer_field="Buffer",
        buffer_length_field="Buffer_Length",
        header_cls=Packet_Header,
        build_header=_build_header,
    )


def create_fault_cls(component_instance_name, entity_name, entity_id, param_type_cls, description=""):
    from fault import Fault
    from fault_header import Fault_Header

    def _build_header(eid, param_size, time):
        return Fault_Header(Time=time, Id=eid, Param_Buffer_Length=param_size)

    return _create_entity_cls(
        Fault, component_instance_name, entity_name, entity_id, param_type_cls, description,
        buffer_field="Param_Buffer",
        buffer_length_field="Param_Buffer_Length",
        header_cls=Fault_Header,
        build_header=_build_header,
    )


def create_parameter_cls(component_instance_name, entity_name, entity_id, param_type_cls, description=""):
    return _create_entity_cls(
        None, component_instance_name, entity_name, entity_id, param_type_cls, description,
    )


def create_parameter_table_cls(component_instance_name, entity_name, entity_id, description=""):
    return _create_entity_cls(
        None, component_instance_name, entity_name, entity_id, None, description,
    )


# Testing code:
if __name__ == "__main__":
    # Build our dependencies using the build system.
    from util import pydep

    pydep.build_py_deps()

    # Imports:
    import sys
    from tick import Tick
    from sys_time import Sys_Time
    from event_header import Event_Header

    # ------------------------------------------------------------------
    # Test 1: Event — auto-header construction
    # ------------------------------------------------------------------
    tick_event_cls = create_event_cls(
        "My_Component", "The_Event", 10, Tick, "A tick event occurred."
    )

    # Construct with just Param + Time — header auto-built:
    t = Sys_Time(15, 7000)
    auto_event = tick_event_cls(
        Param=Tick(Time=t, Count=15),
        Time=t,
    )
    sys.stderr.write("Event auto:   " + auto_event.pretty_print_string() + "\n")
    assert auto_event.Header.Id == 10, "Auto header ID mismatch"
    assert auto_event.Header.Param_Buffer_Length == Tick()._size_in_bytes

    # Construct with explicit Header (deserialization path):
    explicit_event = tick_event_cls(
        Header=Event_Header(Time=t, Id=10, Param_Buffer_Length=Tick()._size_in_bytes),
        Param=Tick(Time=t, Count=15),
    )
    sys.stderr.write("Event expl:   " + explicit_event.pretty_print_string() + "\n")
    assert auto_event == explicit_event, "Auto vs explicit mismatch"

    # Round-trip:
    deser_event = tick_event_cls()
    deser_event.from_byte_array(auto_event.to_byte_array())
    sys.stderr.write("Event deser:  " + deser_event.pretty_print_string() + "\n")
    assert deser_event == auto_event, "Event round-trip failed"

    # Class-level id attribute:
    assert tick_event_cls.id == 10
    sys.stderr.write("Event test PASSED\n\n")

    # ------------------------------------------------------------------
    # Test 2: Data_Product — auto-header construction
    # ------------------------------------------------------------------
    tick_dp_cls = create_data_product_cls(
        "My_Component", "The_Dp", 5, Tick, "A data product."
    )

    auto_dp = tick_dp_cls(
        Param=Tick(Time=Sys_Time(20, 8000), Count=42),
        Time=Sys_Time(20, 8000),
    )
    sys.stderr.write("DP auto:      " + auto_dp.pretty_print_string() + "\n")
    assert auto_dp.Header.Id == 5
    assert auto_dp.Header.Buffer_Length == Tick()._size_in_bytes
    assert tick_dp_cls.id == 5

    deser_dp = tick_dp_cls()
    deser_dp.from_byte_array(auto_dp.to_byte_array())
    assert deser_dp == auto_dp, "Data_Product round-trip failed"
    sys.stderr.write("Data_Product test PASSED\n\n")

    # ------------------------------------------------------------------
    # Test 3: Command — auto-header (no Time)
    # ------------------------------------------------------------------
    tick_cmd_cls = create_command_cls(
        "My_Component", "The_Cmd", 20, Tick, "A command."
    )

    auto_cmd = tick_cmd_cls(Param=Tick(Time=Sys_Time(0, 0), Count=1))
    assert auto_cmd.Header.Id == 20
    assert auto_cmd.Header.Arg_Buffer_Length == Tick()._size_in_bytes
    assert tick_cmd_cls.id == 20
    sys.stderr.write("Command test PASSED\n\n")

    # ------------------------------------------------------------------
    # Test 4: Fault — auto-header construction
    # ------------------------------------------------------------------
    time_fault_cls = create_fault_cls(
        "My_Component", "The_Fault", 7, Sys_Time, "A fault."
    )

    fault_param = Sys_Time(30, 9000)
    auto_fault = time_fault_cls(Param=fault_param, Time=Sys_Time(30, 9000))
    assert auto_fault.Header.Id == 7
    assert time_fault_cls.id == 7

    deser_fault = time_fault_cls()
    deser_fault.from_byte_array(auto_fault.to_byte_array())
    assert deser_fault == auto_fault, "Fault round-trip failed"
    sys.stderr.write("Fault test PASSED\n\n")

    # ------------------------------------------------------------------
    # Test 5: Parameter metadata
    # ------------------------------------------------------------------
    entry_cls = create_parameter_cls("My_Component", "My_Param", 3, Tick, "A parameter.")
    assert entry_cls.id == 3
    assert entry_cls.component_instance_name == "My_Component"
    assert repr(entry_cls()) == "My_Component.My_Param"
    sys.stderr.write("Parameter metadata test PASSED\n\n")

    # ------------------------------------------------------------------
    # Test 6: Parameter table metadata
    # ------------------------------------------------------------------
    table_cls = create_parameter_table_cls("Params_Instance", "My_Table", 1, "A table.")
    assert table_cls.id == 1
    assert repr(table_cls()) == "Params_Instance.My_Table"
    sys.stderr.write("Parameter table metadata test PASSED\n\n")

    # ------------------------------------------------------------------
    # Test 7: No-param event (Param=None)
    # ------------------------------------------------------------------
    bare_event_cls = create_event_cls(
        "My_Component", "Bare_Event", 99, None, "No param."
    )
    bare = bare_event_cls(Time=Sys_Time(1, 0))
    assert bare.Header.Id == 99
    assert bare.Header.Param_Buffer_Length == 0
    assert bare.Param is None
    sys.stderr.write("No-param event test PASSED\n\n")

    sys.stderr.write("All tests PASSED\n")
