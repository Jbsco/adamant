--------------------------------------------------------------------------------
-- Mode_Manager Tests Body
--------------------------------------------------------------------------------

with AUnit.Assertions; use AUnit.Assertions;
with Tick;
with Mode_Manager_Enums;
use Mode_Manager_Enums.System_Mode;
with Packed_Mode_Cmd_Type;
with Command_Enums;
use type Command_Enums.Command_Execution_Status.E;

package body Mode_Manager_Tests.Implementation is

   The_Tick : constant Tick.T := (Time => (0, 0), Count => 1);

   overriding procedure Set_Up_Test (Self : in out Instance) is
   begin
      Self.Tester.Init_Base;
      Self.Tester.Connect;
      Self.Tester.Component_Instance.Init (Initial_Mode => Safe);
      Self.Tester.Component_Instance.Set_Up;
   end Set_Up_Test;

   overriding procedure Tear_Down_Test (Self : in out Instance) is
   begin
      Self.Tester.Final_Base;
   end Tear_Down_Test;

   -- Safe -> Standby -> Nominal -> Science
   overriding procedure Test_Allowed_Transition (Self : in out Instance) is
      T : Component.Mode_Manager.Implementation.Tester.Instance_Access renames Self.Tester;
   begin
      -- Safe -> Standby
      T.Command_T_Send (T.Commands.Set_Mode ((Target_Mode => Standby)));
      Assert (T.Mode_Transition_History.Get_Count = 1, "Expected transition Safe->Standby.");
      Assert (T.Command_Response_T_Recv_Sync_History.Get_Count >= 1, "Expected command response.");

      -- Standby -> Nominal
      T.Command_T_Send (T.Commands.Set_Mode ((Target_Mode => Nominal)));
      Assert (T.Mode_Transition_History.Get_Count = 2, "Expected transition Standby->Nominal.");

      -- Nominal -> Science
      T.Command_T_Send (T.Commands.Set_Mode ((Target_Mode => Science)));
      Assert (T.Mode_Transition_History.Get_Count = 3, "Expected transition Nominal->Science.");
   end Test_Allowed_Transition;

   -- Safe -> Nominal should be rejected
   overriding procedure Test_Rejected_Transition (Self : in out Instance) is
      T : Component.Mode_Manager.Implementation.Tester.Instance_Access renames Self.Tester;
   begin
      T.Command_T_Send (T.Commands.Set_Mode ((Target_Mode => Nominal)));
      Assert (T.Mode_Transition_Rejected_History.Get_Count = 1, "Expected rejection Safe->Nominal.");
      Assert (T.Mode_Transition_History.Get_Count = 0, "No transition should have occurred.");
   end Test_Rejected_Transition;

   -- Force safe from any mode
   overriding procedure Test_Force_Safe_Mode (Self : in out Instance) is
      T : Component.Mode_Manager.Implementation.Tester.Instance_Access renames Self.Tester;
   begin
      -- Go to Standby first
      T.Command_T_Send (T.Commands.Set_Mode ((Target_Mode => Standby)));
      Assert (T.Mode_Transition_History.Get_Count = 1, "Transition to Standby.");

      -- Force safe
      T.Command_T_Send (T.Commands.Force_Safe_Mode);
      Assert (T.Forced_Safe_Mode_History.Get_Count = 1, "Expected Forced_Safe_Mode event.");
      Assert (T.Mode_Transition_History.Get_Count = 2, "Expected transition back to Safe.");
   end Test_Force_Safe_Mode;

   -- Set_Mode to current mode is a no-op success
   overriding procedure Test_Same_Mode_Noop (Self : in out Instance) is
      T : Component.Mode_Manager.Implementation.Tester.Instance_Access renames Self.Tester;
   begin
      -- Already in Safe mode, request Safe
      T.Command_T_Send (T.Commands.Set_Mode ((Target_Mode => Safe)));
      Assert (T.Mode_Transition_History.Get_Count = 0, "No transition for same mode.");
      Assert (T.Mode_Transition_Rejected_History.Get_Count = 0, "No rejection for same mode.");
   end Test_Same_Mode_Noop;

   -- Verify count increments
   overriding procedure Test_Transition_Count (Self : in out Instance) is
      T : Component.Mode_Manager.Implementation.Tester.Instance_Access renames Self.Tester;
   begin
      T.Command_T_Send (T.Commands.Set_Mode ((Target_Mode => Standby)));
      T.Command_T_Send (T.Commands.Set_Mode ((Target_Mode => Nominal)));
      T.Command_T_Send (T.Commands.Set_Mode ((Target_Mode => Science)));

      -- 3 transitions + Set_Up initial = 4 Transition_Count DPs
      Assert (T.Transition_Count_History.Get_Count >= 3, "Expected at least 3 transition count DPs.");
   end Test_Transition_Count;

   -- Verify DP on tick
   overriding procedure Test_Data_Products_On_Tick (Self : in out Instance) is
      T : Component.Mode_Manager.Implementation.Tester.Instance_Access renames Self.Tester;
      Pre_Count : constant Natural := T.Current_Mode_History.Get_Count;
   begin
      T.Tick_T_Send (The_Tick);
      Assert (T.Current_Mode_History.Get_Count = Pre_Count + 1, "Expected Current_Mode DP on tick.");
   end Test_Data_Products_On_Tick;

end Mode_Manager_Tests.Implementation;
