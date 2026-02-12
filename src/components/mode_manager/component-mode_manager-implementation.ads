--------------------------------------------------------------------------------
-- Mode_Manager Component Implementation Spec
--------------------------------------------------------------------------------

with Tick;
with Mode_Manager_Enums;

package Component.Mode_Manager.Implementation is

   type Instance is new Mode_Manager.Base_Instance with private;

   overriding procedure Init (Self : in out Instance; Initial_Mode : in Mode_Manager_Enums.System_Mode.E := Mode_Manager_Enums.System_Mode.Safe);

private

   use Mode_Manager_Enums.System_Mode;

   -- Transition table: Allowed(From, To) = True means transition is permitted
   type Transition_Table is array (Mode_Manager_Enums.System_Mode.E, Mode_Manager_Enums.System_Mode.E) of Boolean;

   -- Allowed transitions:
   --   Safe -> Standby
   --   Standby -> Nominal, Standby -> Safe
   --   Nominal -> Science, Nominal -> Standby
   --   Science -> Nominal, Science -> Standby
   --   Any -> Safe (via Force_Safe_Mode, bypasses table)
   Allowed : constant Transition_Table := [
      Safe    => [Standby => True, others => False],
      Standby => [Nominal => True, Safe => True, others => False],
      Nominal => [Science => True, Standby => True, others => False],
      Science => [Nominal => True, Standby => True, others => False]];

   type Instance is new Mode_Manager.Base_Instance with record
      Current_Mode : Mode_Manager_Enums.System_Mode.E := Safe;
      Transition_Count : Interfaces.Unsigned_16 := 0;
   end record;

   overriding procedure Set_Up (Self : in out Instance);

   overriding procedure Tick_T_Recv_Sync (Self : in out Instance; Arg : in Tick.T);
   overriding procedure Command_T_Recv_Sync (Self : in out Instance; Arg : in Command.T);

   overriding procedure Command_Response_T_Send_Dropped (Self : in out Instance; Arg : in Command_Response.T) is null;
   overriding procedure Data_Product_T_Send_Dropped (Self : in out Instance; Arg : in Data_Product.T) is null;
   overriding procedure Event_T_Send_Dropped (Self : in out Instance; Arg : in Event.T) is null;

   overriding function Set_Mode (Self : in out Instance; Arg : in Packed_Mode_Cmd_Type.T) return Command_Execution_Status.E;
   overriding function Force_Safe_Mode (Self : in out Instance) return Command_Execution_Status.E;

   overriding procedure Invalid_Command (Self : in out Instance; Cmd : in Command.T; Errant_Field_Number : in Unsigned_32; Errant_Field : in Basic_Types.Poly_Type);

end Component.Mode_Manager.Implementation;
