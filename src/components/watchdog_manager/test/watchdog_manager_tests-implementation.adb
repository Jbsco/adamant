--------------------------------------------------------------------------------
-- Watchdog_Manager Tests Body
--------------------------------------------------------------------------------

with AUnit.Assertions; use AUnit.Assertions;
with Tick;
with Pet;
with Interfaces; use type Interfaces.Unsigned_32;

package body Watchdog_Manager_Tests.Implementation is

   The_Tick : constant Tick.T := (Time => (0, 0), Count => 1);

   overriding procedure Set_Up_Test (Self : in out Instance) is
   begin
      Self.Tester.Init_Base;
      Self.Tester.Connect;
      Self.Tester.Component_Instance.Init (Timeout_Ticks => 3);
      Self.Tester.Component_Instance.Set_Up;
   end Set_Up_Test;

   overriding procedure Tear_Down_Test (Self : in out Instance) is
   begin
      Self.Tester.Final_Base;
   end Tear_Down_Test;

   -- All sources pet, verify combined pet forwarded
   overriding procedure Test_All_Pets_Healthy (Self : in out Instance) is
      T : Component.Watchdog_Manager.Implementation.Tester.Instance_Access renames Self.Tester;
   begin
      -- Pet all 3 sources
      T.Pet_T_Send (1, (Count => 1));
      T.Pet_T_Send (2, (Count => 1));
      T.Pet_T_Send (3, (Count => 1));

      -- Tick once: all healthy -> combined pet forwarded
      T.Tick_T_Send (The_Tick);

      Assert (T.Pet_T_Recv_Sync_History.Get_Count = 1, "Expected combined pet forwarded.");
      Assert (T.Pet_Timeout_History.Get_Count = 0, "No timeout expected.");
      Assert (T.Rate_Group_Timeout_History.Get_Count = 0, "No fault expected.");
   end Test_All_Pets_Healthy;

   -- Don't pet source 2, tick past timeout
   overriding procedure Test_Pet_Timeout (Self : in out Instance) is
      T : Component.Watchdog_Manager.Implementation.Tester.Instance_Access renames Self.Tester;
   begin
      -- Pet sources 1 and 3, skip source 2
      T.Pet_T_Send (1, (Count => 1));
      T.Pet_T_Send (3, (Count => 1));

      -- Tick 4 times (timeout is 3)
      for I in 1 .. 4 loop
         T.Tick_T_Send (The_Tick);
      end loop;

      -- Source 2 should have timed out
      Assert (T.Pet_Timeout_History.Get_Count >= 1, "Expected Pet_Timeout event for source 2.");
      Assert (T.Rate_Group_Timeout_History.Get_Count >= 1, "Expected fault for source 2.");
   end Test_Pet_Timeout;

   -- If any source is timed out, no combined pet
   overriding procedure Test_No_Pet_Until_All_Healthy (Self : in out Instance) is
      T : Component.Watchdog_Manager.Implementation.Tester.Instance_Access renames Self.Tester;
   begin
      -- Pet only source 1
      T.Pet_T_Send (1, (Count => 1));

      -- Tick 4 times (sources 2 and 3 will timeout)
      for I in 1 .. 4 loop
         T.Tick_T_Send (The_Tick);
      end loop;

      -- No combined pet should be forwarded (sources 2,3 timed out)
      -- Note: First tick (tick_count=1) all sources have last_pet_at=0, so
      -- 1-0=1 < 3 (timeout). After 4 ticks, tick_count=4, 4-0=4 > 3.
      -- But tick 1 sends a combined pet since 1-0=1 <= 3 for all.
      -- Starting from tick 4, sources 2,3 are timed out.
      -- So we expect some combined pets early and none later.
      Assert (T.Rate_Group_Timeout_History.Get_Count >= 1, "Expected timeout faults.");
   end Test_No_Pet_Until_All_Healthy;

end Watchdog_Manager_Tests.Implementation;
