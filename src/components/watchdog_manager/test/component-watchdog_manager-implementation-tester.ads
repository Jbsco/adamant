--------------------------------------------------------------------------------
-- Watchdog_Manager Component Tester Spec
--------------------------------------------------------------------------------

-- Includes:
with Component.Watchdog_Manager_Reciprocal;
with Printable_History;
with Sys_Time.Representation;
with Pet.Representation;
with Event.Representation;
with Fault.Representation;
with Data_Product.Representation;
with Event;
with Packed_U16.Representation;
with Fault;
with Data_Product;
with Packed_U32.Representation;

-- Aggregates watchdog pets from multiple rate groups. Detects missed pets and
-- raises faults. Optionally forwards a combined pet to an external hardware
-- watchdog.
package Component.Watchdog_Manager.Implementation.Tester is

   use Component.Watchdog_Manager_Reciprocal;
   -- Invoker connector history packages:
   package Sys_Time_T_Return_History_Package is new Printable_History (Sys_Time.T, Sys_Time.Representation.Image);
   package Pet_T_Recv_Sync_History_Package is new Printable_History (Pet.T, Pet.Representation.Image);
   package Event_T_Recv_Sync_History_Package is new Printable_History (Event.T, Event.Representation.Image);
   package Fault_T_Recv_Sync_History_Package is new Printable_History (Fault.T, Fault.Representation.Image);
   package Data_Product_T_Recv_Sync_History_Package is new Printable_History (Data_Product.T, Data_Product.Representation.Image);

   -- Event history packages:
   package Pet_Received_History_Package is new Printable_History (Pet.T, Pet.Representation.Image);
   package Pet_Timeout_History_Package is new Printable_History (Packed_U16.T, Packed_U16.Representation.Image);
   package All_Pets_Healthy_History_Package is new Printable_History (Natural, Natural'Image);

   -- Data product history packages:
   package Combined_Pet_Count_History_Package is new Printable_History (Packed_U32.T, Packed_U32.Representation.Image);

   -- Fault history packages:
   package Rate_Group_Timeout_History_Package is new Printable_History (Packed_U16.T, Packed_U16.Representation.Image);

   -- Component class instance:
   type Instance is new Component.Watchdog_Manager_Reciprocal.Base_Instance with record
      -- The component instance under test:
      Component_Instance : aliased Component.Watchdog_Manager.Implementation.Instance;
      -- Connector histories:
      Sys_Time_T_Return_History : Sys_Time_T_Return_History_Package.Instance;
      Pet_T_Recv_Sync_History : Pet_T_Recv_Sync_History_Package.Instance;
      Event_T_Recv_Sync_History : Event_T_Recv_Sync_History_Package.Instance;
      Fault_T_Recv_Sync_History : Fault_T_Recv_Sync_History_Package.Instance;
      Data_Product_T_Recv_Sync_History : Data_Product_T_Recv_Sync_History_Package.Instance;
      -- Event histories:
      Pet_Received_History : Pet_Received_History_Package.Instance;
      Pet_Timeout_History : Pet_Timeout_History_Package.Instance;
      All_Pets_Healthy_History : All_Pets_Healthy_History_Package.Instance;
      -- Data product histories:
      Combined_Pet_Count_History : Combined_Pet_Count_History_Package.Instance;
      -- Fault histories:
      Rate_Group_Timeout_History : Rate_Group_Timeout_History_Package.Instance;
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
   -- Get current system time.
   overriding function Sys_Time_T_Return (Self : in out Instance) return Sys_Time.T;
   -- Send combined pet to hardware watchdog.
   overriding procedure Pet_T_Recv_Sync (Self : in out Instance; Arg : in Pet.T);
   -- Send events.
   overriding procedure Event_T_Recv_Sync (Self : in out Instance; Arg : in Event.T);
   -- Send faults.
   overriding procedure Fault_T_Recv_Sync (Self : in out Instance; Arg : in Fault.T);
   -- Send data products.
   overriding procedure Data_Product_T_Recv_Sync (Self : in out Instance; Arg : in Data_Product.T);

   -----------------------------------------------
   -- Event handler primitive:
   -----------------------------------------------
   -- Description:
   --    Events for watchdog manager.
   -- A pet was received from a rate group.
   overriding procedure Pet_Received (Self : in out Instance; Arg : in Pet.T);
   -- A rate group missed its pet deadline.
   overriding procedure Pet_Timeout (Self : in out Instance; Arg : in Packed_U16.T);
   -- All rate groups are petting on time.
   overriding procedure All_Pets_Healthy (Self : in out Instance);

   -----------------------------------------------
   -- Data product handler primitives:
   -----------------------------------------------
   -- Description:
   --    Data products for watchdog manager.
   -- Total combined pet count forwarded to hardware watchdog.
   overriding procedure Combined_Pet_Count (Self : in out Instance; Arg : in Packed_U32.T);

   -----------------------------------------------
   -- Fault handler primitive:
   -----------------------------------------------
   -- Description:
   --    Faults for watchdog manager.
   -- A rate group failed to pet within the timeout period.
   overriding procedure Rate_Group_Timeout (Self : in out Instance; Arg : in Packed_U16.T);

end Component.Watchdog_Manager.Implementation.Tester;
