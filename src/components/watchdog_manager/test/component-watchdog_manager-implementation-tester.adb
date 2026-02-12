--------------------------------------------------------------------------------
-- Watchdog_Manager Component Tester Body
--------------------------------------------------------------------------------

package body Component.Watchdog_Manager.Implementation.Tester is

   ---------------------------------------
   -- Initialize heap variables:
   ---------------------------------------
   procedure Init_Base (Self : in out Instance) is
   begin
      -- Initialize tester heap:
      -- Connector histories:
      Self.Sys_Time_T_Return_History.Init (Depth => 100);
      Self.Pet_T_Recv_Sync_History.Init (Depth => 100);
      Self.Event_T_Recv_Sync_History.Init (Depth => 100);
      Self.Fault_T_Recv_Sync_History.Init (Depth => 100);
      Self.Data_Product_T_Recv_Sync_History.Init (Depth => 100);
      -- Event histories:
      Self.Pet_Received_History.Init (Depth => 100);
      Self.Pet_Timeout_History.Init (Depth => 100);
      Self.All_Pets_Healthy_History.Init (Depth => 100);
      -- Data product histories:
      Self.Combined_Pet_Count_History.Init (Depth => 100);
      -- Fault histories:
      Self.Rate_Group_Timeout_History.Init (Depth => 100);
   end Init_Base;

   procedure Final_Base (Self : in out Instance) is
   begin
      -- Destroy tester heap:
      -- Connector histories:
      Self.Sys_Time_T_Return_History.Destroy;
      Self.Pet_T_Recv_Sync_History.Destroy;
      Self.Event_T_Recv_Sync_History.Destroy;
      Self.Fault_T_Recv_Sync_History.Destroy;
      Self.Data_Product_T_Recv_Sync_History.Destroy;
      -- Event histories:
      Self.Pet_Received_History.Destroy;
      Self.Pet_Timeout_History.Destroy;
      Self.All_Pets_Healthy_History.Destroy;
      -- Data product histories:
      Self.Combined_Pet_Count_History.Destroy;
      -- Fault histories:
      Self.Rate_Group_Timeout_History.Destroy;
   end Final_Base;

   ---------------------------------------
   -- Test initialization functions:
   ---------------------------------------
   procedure Connect (Self : in out Instance) is
   begin
      Self.Component_Instance.Attach_Sys_Time_T_Get (To_Component => Self'Unchecked_Access, Hook => Self.Sys_Time_T_Return_Access);
      Self.Component_Instance.Attach_Pet_T_Send (To_Component => Self'Unchecked_Access, Hook => Self.Pet_T_Recv_Sync_Access);
      Self.Component_Instance.Attach_Event_T_Send (To_Component => Self'Unchecked_Access, Hook => Self.Event_T_Recv_Sync_Access);
      Self.Component_Instance.Attach_Fault_T_Send (To_Component => Self'Unchecked_Access, Hook => Self.Fault_T_Recv_Sync_Access);
      Self.Component_Instance.Attach_Data_Product_T_Send (To_Component => Self'Unchecked_Access, Hook => Self.Data_Product_T_Recv_Sync_Access);
      for Idx in Self.Connector_Pet_T_Send'Range loop
         Self.Attach_Pet_T_Send (From_Index => Idx, To_Component => Self.Component_Instance'Unchecked_Access, Hook => Self.Component_Instance.Pet_T_Recv_Sync_Access (Index => Idx), To_Index => Idx);
      end loop;
      Self.Attach_Tick_T_Send (To_Component => Self.Component_Instance'Unchecked_Access, Hook => Self.Component_Instance.Tick_T_Recv_Sync_Access);
   end Connect;

   ---------------------------------------
   -- Invokee connector primitives:
   ---------------------------------------
   -- Get current system time.
   overriding function Sys_Time_T_Return (Self : in out Instance) return Sys_Time.T is
      -- Return the system time:
      To_Return : constant Sys_Time.T := Self.System_Time;
   begin
      -- Push the argument onto the test history for looking at later:
      Self.Sys_Time_T_Return_History.Push (To_Return);
      return To_Return;
   end Sys_Time_T_Return;

   -- Send combined pet to hardware watchdog.
   overriding procedure Pet_T_Recv_Sync (Self : in out Instance; Arg : in Pet.T) is
   begin
      -- Push the argument onto the test history for looking at later:
      Self.Pet_T_Recv_Sync_History.Push (Arg);
   end Pet_T_Recv_Sync;

   -- Send events.
   overriding procedure Event_T_Recv_Sync (Self : in out Instance; Arg : in Event.T) is
   begin
      -- Push the argument onto the test history for looking at later:
      Self.Event_T_Recv_Sync_History.Push (Arg);
      -- Dispatch the event to the correct handler:
      Self.Dispatch_Event (Arg);
   end Event_T_Recv_Sync;

   -- Send faults.
   overriding procedure Fault_T_Recv_Sync (Self : in out Instance; Arg : in Fault.T) is
   begin
      -- Push the argument onto the test history for looking at later:
      Self.Fault_T_Recv_Sync_History.Push (Arg);
      -- Dispatch the fault to the correct handler:
      Self.Dispatch_Fault (Arg);
   end Fault_T_Recv_Sync;

   -- Send data products.
   overriding procedure Data_Product_T_Recv_Sync (Self : in out Instance; Arg : in Data_Product.T) is
   begin
      -- Push the argument onto the test history for looking at later:
      Self.Data_Product_T_Recv_Sync_History.Push (Arg);
      -- Dispatch the data product to the correct handler:
      Self.Dispatch_Data_Product (Arg);
   end Data_Product_T_Recv_Sync;

   -----------------------------------------------
   -- Event handler primitive:
   -----------------------------------------------
   -- Description:
   --    Events for watchdog manager.
   -- A pet was received from a rate group.
   overriding procedure Pet_Received (Self : in out Instance; Arg : in Pet.T) is
   begin
      -- Push the argument onto the test history for looking at later:
      Self.Pet_Received_History.Push (Arg);
   end Pet_Received;

   -- A rate group missed its pet deadline.
   overriding procedure Pet_Timeout (Self : in out Instance; Arg : in Packed_U16.T) is
   begin
      -- Push the argument onto the test history for looking at later:
      Self.Pet_Timeout_History.Push (Arg);
   end Pet_Timeout;

   -- All rate groups are petting on time.
   overriding procedure All_Pets_Healthy (Self : in out Instance) is
      Arg : constant Natural := 0;
   begin
      -- Push the argument onto the test history for looking at later:
      Self.All_Pets_Healthy_History.Push (Arg);
   end All_Pets_Healthy;

   -----------------------------------------------
   -- Data product handler primitive:
   -----------------------------------------------
   -- Description:
   --    Data products for watchdog manager.
   -- Total combined pet count forwarded to hardware watchdog.
   overriding procedure Combined_Pet_Count (Self : in out Instance; Arg : in Packed_U32.T) is
   begin
      -- Push the argument onto the test history for looking at later:
      Self.Combined_Pet_Count_History.Push (Arg);
   end Combined_Pet_Count;

   -----------------------------------------------
   -- Fault handler primitive:
   -----------------------------------------------
   -- Description:
   --    Faults for watchdog manager.
   -- A rate group failed to pet within the timeout period.
   overriding procedure Rate_Group_Timeout (Self : in out Instance; Arg : in Packed_U16.T) is
   begin
      -- Push the argument onto the test history for looking at later:
      Self.Rate_Group_Timeout_History.Push (Arg);
   end Rate_Group_Timeout;

end Component.Watchdog_Manager.Implementation.Tester;
