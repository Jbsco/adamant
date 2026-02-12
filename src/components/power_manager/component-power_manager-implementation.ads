--------------------------------------------------------------------------------
-- Power_Manager Component Implementation Spec
--------------------------------------------------------------------------------

with Tick;
with Command;
with Power_Manager_Enums;

-- Monitors battery voltage and solar panel current. Manages power bus
-- enable/disable and load shedding based on battery state of charge.
package Component.Power_Manager.Implementation is

   type Instance is new Power_Manager.Base_Instance with private;

   overriding procedure Init (Self : in out Instance; Undervoltage_Limit : in Interfaces.Unsigned_16 := 2800; Overvoltage_Limit : in Interfaces.Unsigned_16 := 4200; Nominal_Voltage : in Interfaces.Unsigned_16 := 3700);

private

   type Instance is new Power_Manager.Base_Instance with record
      Undervoltage_Limit : Interfaces.Unsigned_16 := 2800;
      Overvoltage_Limit : Interfaces.Unsigned_16 := 4200;
      Nominal_Voltage : Interfaces.Unsigned_16 := 3700;
      -- Simulated state:
      Battery_Mv : Interfaces.Unsigned_16 := 3700;
      Solar_Ma : Interfaces.Unsigned_16 := 500;
      Load_Ma : Interfaces.Unsigned_16 := 200;
      Bus_State : Power_Manager_Enums.Power_Bus_State.E := Power_Manager_Enums.Power_Bus_State.Nominal;
      Fault_Count : Interfaces.Unsigned_16 := 0;
      Forced : Boolean := False;
   end record;

   overriding procedure Set_Up (Self : in out Instance);

   overriding procedure Tick_T_Recv_Sync (Self : in out Instance; Arg : in Tick.T);
   overriding procedure Command_T_Recv_Sync (Self : in out Instance; Arg : in Command.T);

   overriding procedure Command_Response_T_Send_Dropped (Self : in out Instance; Arg : in Command_Response.T) is null;
   overriding procedure Data_Product_T_Send_Dropped (Self : in out Instance; Arg : in Data_Product.T) is null;
   overriding procedure Event_T_Send_Dropped (Self : in out Instance; Arg : in Event.T) is null;
   overriding procedure Fault_T_Send_Dropped (Self : in out Instance; Arg : in Fault.T) is null;

   overriding function Force_State (Self : in out Instance; Arg : in Packed_Power_Bus_State.T) return Command_Execution_Status.E;
   overriding function Clear_Faults (Self : in out Instance) return Command_Execution_Status.E;
   overriding procedure Invalid_Command (Self : in out Instance; Cmd : in Command.T; Errant_Field_Number : in Unsigned_32; Errant_Field : in Basic_Types.Poly_Type);

end Component.Power_Manager.Implementation;
