--------------------------------------------------------------------------------
-- Telemetry_Manager Component Implementation Spec
--------------------------------------------------------------------------------

with Data_Product;
with Command;

package Component.Telemetry_Manager.Implementation is

   type Instance is new Telemetry_Manager.Base_Instance with private;

   overriding procedure Init (Self : in out Instance; Queue_Size : in Natural := 10);

private

   type Instance is new Telemetry_Manager.Base_Instance with record
      Forwarded_Count : Natural := 0;
      Dropped_Count : Natural := 0;
   end record;

   overriding procedure Set_Up (Self : in out Instance);

   -- Async recv handler (called by Cycle after dequeue):
   overriding procedure Data_Product_T_Recv_Async (Self : in out Instance; Arg : in Data_Product.T);
   -- Queue overflow handler:
   overriding procedure Data_Product_T_Recv_Async_Dropped (Self : in out Instance; Arg : in Data_Product.T);
   -- Sync command handler:
   overriding procedure Command_T_Recv_Sync (Self : in out Instance; Arg : in Command.T);

   -- Invoker dropped handlers:
   overriding procedure Command_Response_T_Send_Dropped (Self : in out Instance; Arg : in Command_Response.T) is null;
   overriding procedure Data_Product_T_Send_Dropped (Self : in out Instance; Arg : in Data_Product.T) is null;
   overriding procedure Event_T_Send_Dropped (Self : in out Instance; Arg : in Event.T) is null;

   -- Command handlers:
   overriding function Reset_Count (Self : in out Instance) return Command_Execution_Status.E;
   overriding procedure Invalid_Command (Self : in out Instance; Cmd : in Command.T; Errant_Field_Number : in Unsigned_32; Errant_Field : in Basic_Types.Poly_Type);

end Component.Telemetry_Manager.Implementation;
