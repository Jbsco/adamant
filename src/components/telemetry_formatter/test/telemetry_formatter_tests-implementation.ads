--------------------------------------------------------------------------------
-- Telemetry_Formatter Tests Spec
--------------------------------------------------------------------------------

-- Unit tests for the Telemetry_Formatter component.
package Telemetry_Formatter_Tests.Implementation is

   -- Test data and state:
   type Instance is new Telemetry_Formatter_Tests.Base_Instance with private;
   type Class_Access is access all Instance'Class;

private
   -- Fixture procedures:
   overriding procedure Set_Up_Test (Self : in out Instance);
   overriding procedure Tear_Down_Test (Self : in out Instance);

   -- Verify packet emitted at the configured period.
   overriding procedure Test_Packet_Emission (Self : in out Instance);
   -- Verify no packet emitted before period elapses.
   overriding procedure Test_No_Packet_Before_Period (Self : in out Instance);
   -- Verify sequence count increments with each packet.
   overriding procedure Test_Sequence_Count (Self : in out Instance);

   -- Test data and state:
   type Instance is new Telemetry_Formatter_Tests.Base_Instance with record
      null;
   end record;
end Telemetry_Formatter_Tests.Implementation;
