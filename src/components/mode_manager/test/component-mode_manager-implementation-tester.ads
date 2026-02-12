--------------------------------------------------------------------------------
-- Mode_Manager Component Tester Spec
--------------------------------------------------------------------------------

-- Includes:
with Component.Mode_Manager_Reciprocal;
with Printable_History;
with Command_Response.Representation;
with Sys_Time.Representation;
with Data_Product.Representation;
with Event.Representation;
with Data_Product;
with Packed_Mode_Cmd_Type.Representation;
with Packed_U16.Representation;
with Event;
with Packed_Mode_Transition.Representation;
with Invalid_Command_Info.Representation;

-- Manages spacecraft operating modes with guarded transitions. Validates mode
-- transition requests against allowed transition table. Publishes current mode as
-- a data product for other components to consume via data dependencies.
package Component.Mode_Manager.Implementation.Tester is

   use Component.Mode_Manager_Reciprocal;
   -- Invoker connector history packages:
   package Command_Response_T_Recv_Sync_History_Package is new Printable_History (Command_Response.T, Command_Response.Representation.Image);
   package Sys_Time_T_Return_History_Package is new Printable_History (Sys_Time.T, Sys_Time.Representation.Image);
   package Data_Product_T_Recv_Sync_History_Package is new Printable_History (Data_Product.T, Data_Product.Representation.Image);
   package Event_T_Recv_Sync_History_Package is new Printable_History (Event.T, Event.Representation.Image);

   -- Event history packages:
   package Mode_Transition_History_Package is new Printable_History (Packed_Mode_Transition.T, Packed_Mode_Transition.Representation.Image);
   package Mode_Transition_Rejected_History_Package is new Printable_History (Packed_Mode_Transition.T, Packed_Mode_Transition.Representation.Image);
   package Forced_Safe_Mode_History_Package is new Printable_History (Natural, Natural'Image);
   package Invalid_Command_Received_History_Package is new Printable_History (Invalid_Command_Info.T, Invalid_Command_Info.Representation.Image);

   -- Data product history packages:
   package Current_Mode_History_Package is new Printable_History (Packed_Mode_Cmd_Type.T, Packed_Mode_Cmd_Type.Representation.Image);
   package Transition_Count_History_Package is new Printable_History (Packed_U16.T, Packed_U16.Representation.Image);

   -- Component class instance:
   type Instance is new Component.Mode_Manager_Reciprocal.Base_Instance with record
      -- The component instance under test:
      Component_Instance : aliased Component.Mode_Manager.Implementation.Instance;
      -- Connector histories:
      Command_Response_T_Recv_Sync_History : Command_Response_T_Recv_Sync_History_Package.Instance;
      Sys_Time_T_Return_History : Sys_Time_T_Return_History_Package.Instance;
      Data_Product_T_Recv_Sync_History : Data_Product_T_Recv_Sync_History_Package.Instance;
      Event_T_Recv_Sync_History : Event_T_Recv_Sync_History_Package.Instance;
      -- Event histories:
      Mode_Transition_History : Mode_Transition_History_Package.Instance;
      Mode_Transition_Rejected_History : Mode_Transition_Rejected_History_Package.Instance;
      Forced_Safe_Mode_History : Forced_Safe_Mode_History_Package.Instance;
      Invalid_Command_Received_History : Invalid_Command_Received_History_Package.Instance;
      -- Data product histories:
      Current_Mode_History : Current_Mode_History_Package.Instance;
      Transition_Count_History : Transition_Count_History_Package.Instance;
   end record;
   type Instance_Access is access all Instance;

   ---------------------------------------
   -- Initialize component heap variables:
   ---------------------------------------
   procedure Init_Base (Self : in out Instance);
   procedure Final_Base (Self : in out Instance);

   ---------------------------------------
   -- Test initialization functions:
   ---------------------------------------
   procedure Connect (Self : in out Instance);

   ---------------------------------------
   -- Invokee connector primitives:
   ---------------------------------------
   -- Send command responses.
   overriding procedure Command_Response_T_Recv_Sync (Self : in out Instance; Arg : in Command_Response.T);
   -- Get current system time.
   overriding function Sys_Time_T_Return (Self : in out Instance) return Sys_Time.T;
   -- Send data products.
   overriding procedure Data_Product_T_Recv_Sync (Self : in out Instance; Arg : in Data_Product.T);
   -- Send events.
   overriding procedure Event_T_Recv_Sync (Self : in out Instance; Arg : in Event.T);

   -----------------------------------------------
   -- Event handler primitive:
   -----------------------------------------------
   -- Description:
   --    Events for mode manager.
   -- Mode transition completed.
   overriding procedure Mode_Transition (Self : in out Instance; Arg : in Packed_Mode_Transition.T);
   -- Mode transition request was rejected (invalid transition).
   overriding procedure Mode_Transition_Rejected (Self : in out Instance; Arg : in Packed_Mode_Transition.T);
   -- Forced transition to Safe mode.
   overriding procedure Forced_Safe_Mode (Self : in out Instance);
   -- Received command with invalid arguments.
   overriding procedure Invalid_Command_Received (Self : in out Instance; Arg : in Invalid_Command_Info.T);

   -----------------------------------------------
   -- Data product handler primitives:
   -----------------------------------------------
   -- Description:
   --    Data products for mode manager.
   -- Current spacecraft operating mode.
   overriding procedure Current_Mode (Self : in out Instance; Arg : in Packed_Mode_Cmd_Type.T);
   -- Total number of mode transitions since boot.
   overriding procedure Transition_Count (Self : in out Instance; Arg : in Packed_U16.T);

end Component.Mode_Manager.Implementation.Tester;
