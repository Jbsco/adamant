--------------------------------------------------------------------------------
-- Mode_Manager Tests Spec
--------------------------------------------------------------------------------

-- Unit tests for the Mode_Manager component.
package Mode_Manager_Tests.Implementation is

   -- Test data and state:
   type Instance is new Mode_Manager_Tests.Base_Instance with private;
   type Class_Access is access all Instance'Class;

private
   -- Fixture procedures:
   overriding procedure Set_Up_Test (Self : in out Instance);
   overriding procedure Tear_Down_Test (Self : in out Instance);

   -- Verify Safe -> Standby -> Nominal -> Science transitions succeed.
   overriding procedure Test_Allowed_Transition (Self : in out Instance);
   -- Verify Safe -> Nominal is rejected (not in transition table).
   overriding procedure Test_Rejected_Transition (Self : in out Instance);
   -- Verify Force_Safe_Mode always transitions to Safe from any mode.
   overriding procedure Test_Force_Safe_Mode (Self : in out Instance);
   -- Verify requesting current mode returns success with no transition event.
   overriding procedure Test_Same_Mode_Noop (Self : in out Instance);
   -- Verify transition count increments correctly.
   overriding procedure Test_Transition_Count (Self : in out Instance);
   -- Verify current mode data product emitted on tick.
   overriding procedure Test_Data_Products_On_Tick (Self : in out Instance);

   -- Test data and state:
   type Instance is new Mode_Manager_Tests.Base_Instance with record
      null;
   end record;
end Mode_Manager_Tests.Implementation;
