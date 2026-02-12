--------------------------------------------------------------------------------
-- Mode_Manager Component Tester Body
--------------------------------------------------------------------------------

package body Component.Mode_Manager.Implementation.Tester is

   ---------------------------------------
   -- Initialize heap variables:
   ---------------------------------------
   procedure Init_Base (Self : in out Instance) is
   begin
      -- Initialize tester heap:
      -- Connector histories:
      Self.Command_Response_T_Recv_Sync_History.Init (Depth => 100);
      Self.Sys_Time_T_Return_History.Init (Depth => 100);
      Self.Data_Product_T_Recv_Sync_History.Init (Depth => 100);
      Self.Event_T_Recv_Sync_History.Init (Depth => 100);
      -- Event histories:
      Self.Mode_Transition_History.Init (Depth => 100);
      Self.Mode_Transition_Rejected_History.Init (Depth => 100);
      Self.Forced_Safe_Mode_History.Init (Depth => 100);
      Self.Invalid_Command_Received_History.Init (Depth => 100);
      -- Data product histories:
      Self.Current_Mode_History.Init (Depth => 100);
      Self.Transition_Count_History.Init (Depth => 100);
   end Init_Base;

   procedure Final_Base (Self : in out Instance) is
   begin
      -- Destroy tester heap:
      -- Connector histories:
      Self.Command_Response_T_Recv_Sync_History.Destroy;
      Self.Sys_Time_T_Return_History.Destroy;
      Self.Data_Product_T_Recv_Sync_History.Destroy;
      Self.Event_T_Recv_Sync_History.Destroy;
      -- Event histories:
      Self.Mode_Transition_History.Destroy;
      Self.Mode_Transition_Rejected_History.Destroy;
      Self.Forced_Safe_Mode_History.Destroy;
      Self.Invalid_Command_Received_History.Destroy;
      -- Data product histories:
      Self.Current_Mode_History.Destroy;
      Self.Transition_Count_History.Destroy;
   end Final_Base;

   ---------------------------------------
   -- Test initialization functions:
   ---------------------------------------
   procedure Connect (Self : in out Instance) is
   begin
      Self.Component_Instance.Attach_Command_Response_T_Send (To_Component => Self'Unchecked_Access, Hook => Self.Command_Response_T_Recv_Sync_Access);
      Self.Component_Instance.Attach_Sys_Time_T_Get (To_Component => Self'Unchecked_Access, Hook => Self.Sys_Time_T_Return_Access);
      Self.Component_Instance.Attach_Data_Product_T_Send (To_Component => Self'Unchecked_Access, Hook => Self.Data_Product_T_Recv_Sync_Access);
      Self.Component_Instance.Attach_Event_T_Send (To_Component => Self'Unchecked_Access, Hook => Self.Event_T_Recv_Sync_Access);
      Self.Attach_Tick_T_Send (To_Component => Self.Component_Instance'Unchecked_Access, Hook => Self.Component_Instance.Tick_T_Recv_Sync_Access);
      Self.Attach_Command_T_Send (To_Component => Self.Component_Instance'Unchecked_Access, Hook => Self.Component_Instance.Command_T_Recv_Sync_Access);
   end Connect;

   ---------------------------------------
   -- Invokee connector primitives:
   ---------------------------------------
   -- Send command responses.
   overriding procedure Command_Response_T_Recv_Sync (Self : in out Instance; Arg : in Command_Response.T) is
   begin
      -- Push the argument onto the test history for looking at later:
      Self.Command_Response_T_Recv_Sync_History.Push (Arg);
   end Command_Response_T_Recv_Sync;

   -- Get current system time.
   overriding function Sys_Time_T_Return (Self : in out Instance) return Sys_Time.T is
      -- Return the system time:
      To_Return : constant Sys_Time.T := Self.System_Time;
   begin
      -- Push the argument onto the test history for looking at later:
      Self.Sys_Time_T_Return_History.Push (To_Return);
      return To_Return;
   end Sys_Time_T_Return;

   -- Send data products.
   overriding procedure Data_Product_T_Recv_Sync (Self : in out Instance; Arg : in Data_Product.T) is
   begin
      -- Push the argument onto the test history for looking at later:
      Self.Data_Product_T_Recv_Sync_History.Push (Arg);
      -- Dispatch the data product to the correct handler:
      Self.Dispatch_Data_Product (Arg);
   end Data_Product_T_Recv_Sync;

   -- Send events.
   overriding procedure Event_T_Recv_Sync (Self : in out Instance; Arg : in Event.T) is
   begin
      -- Push the argument onto the test history for looking at later:
      Self.Event_T_Recv_Sync_History.Push (Arg);
      -- Dispatch the event to the correct handler:
      Self.Dispatch_Event (Arg);
   end Event_T_Recv_Sync;

   -----------------------------------------------
   -- Event handler primitive:
   -----------------------------------------------
   -- Description:
   --    Events for mode manager.
   -- Mode transition completed.
   overriding procedure Mode_Transition (Self : in out Instance; Arg : in Packed_Mode_Transition.T) is
   begin
      -- Push the argument onto the test history for looking at later:
      Self.Mode_Transition_History.Push (Arg);
   end Mode_Transition;

   -- Mode transition request was rejected (invalid transition).
   overriding procedure Mode_Transition_Rejected (Self : in out Instance; Arg : in Packed_Mode_Transition.T) is
   begin
      -- Push the argument onto the test history for looking at later:
      Self.Mode_Transition_Rejected_History.Push (Arg);
   end Mode_Transition_Rejected;

   -- Forced transition to Safe mode.
   overriding procedure Forced_Safe_Mode (Self : in out Instance) is
      Arg : constant Natural := 0;
   begin
      -- Push the argument onto the test history for looking at later:
      Self.Forced_Safe_Mode_History.Push (Arg);
   end Forced_Safe_Mode;

   -- Received command with invalid arguments.
   overriding procedure Invalid_Command_Received (Self : in out Instance; Arg : in Invalid_Command_Info.T) is
   begin
      -- Push the argument onto the test history for looking at later:
      Self.Invalid_Command_Received_History.Push (Arg);
   end Invalid_Command_Received;

   -----------------------------------------------
   -- Data product handler primitive:
   -----------------------------------------------
   -- Description:
   --    Data products for mode manager.
   -- Current spacecraft operating mode.
   overriding procedure Current_Mode (Self : in out Instance; Arg : in Packed_Mode_Cmd_Type.T) is
   begin
      -- Push the argument onto the test history for looking at later:
      Self.Current_Mode_History.Push (Arg);
   end Current_Mode;

   -- Total number of mode transitions since boot.
   overriding procedure Transition_Count (Self : in out Instance; Arg : in Packed_U16.T) is
   begin
      -- Push the argument onto the test history for looking at later:
      Self.Transition_Count_History.Push (Arg);
   end Transition_Count;

end Component.Mode_Manager.Implementation.Tester;
