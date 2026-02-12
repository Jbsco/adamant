--------------------------------------------------------------------------------
-- Watchdog_Manager Tests Spec
--------------------------------------------------------------------------------

-- Unit tests for the Watchdog_Manager component.
package Watchdog_Manager_Tests.Implementation is

   -- Test data and state:
   type Instance is new Watchdog_Manager_Tests.Base_Instance with private;
   type Class_Access is access all Instance'Class;

private
   -- Fixture procedures:
   overriding procedure Set_Up_Test (Self : in out Instance);
   overriding procedure Tear_Down_Test (Self : in out Instance);

   -- Verify combined pet forwarded when all sources are healthy.
   overriding procedure Test_All_Pets_Healthy (Self : in out Instance);
   -- Verify fault and event when a source misses its pet deadline.
   overriding procedure Test_Pet_Timeout (Self : in out Instance);
   -- Verify no combined pet forwarded if any source is timed out.
   overriding procedure Test_No_Pet_Until_All_Healthy (Self : in out Instance);

   -- Test data and state:
   type Instance is new Watchdog_Manager_Tests.Base_Instance with record
      null;
   end record;
end Watchdog_Manager_Tests.Implementation;
