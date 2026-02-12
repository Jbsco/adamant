--------------------------------------------------------------------------------
-- Orbit_Propagator Component Implementation Spec
--------------------------------------------------------------------------------

with Tick;
with Command;
with Parameter_Update;
with Ada.Numerics.Generic_Elementary_Functions;

package Component.Orbit_Propagator.Implementation is

   type Instance is new Orbit_Propagator.Base_Instance with private;

   overriding procedure Init (Self : in out Instance; Dt : in Interfaces.IEEE_Float_32 := 1.0);

private

   package Float_Math is new Ada.Numerics.Generic_Elementary_Functions (Interfaces.IEEE_Float_32);

   type Instance is new Orbit_Propagator.Base_Instance with record
      Dt : Interfaces.IEEE_Float_32 := 1.0;
      -- Current state vector:
      Px : Interfaces.IEEE_Float_32 := 0.0;
      Py : Interfaces.IEEE_Float_32 := 0.0;
      Pz : Interfaces.IEEE_Float_32 := 0.0;
      Vx : Interfaces.IEEE_Float_32 := 0.0;
      Vy : Interfaces.IEEE_Float_32 := 0.0;
      Vz : Interfaces.IEEE_Float_32 := 0.0;
      Prop_Count : Natural := 0;
   end record;

   overriding procedure Set_Up (Self : in out Instance);

   overriding procedure Tick_T_Recv_Sync (Self : in out Instance; Arg : in Tick.T);
   overriding procedure Command_T_Recv_Sync (Self : in out Instance; Arg : in Command.T);
   overriding procedure Parameter_Update_T_Modify (Self : in out Instance; Arg : in out Parameter_Update.T);

   overriding procedure Command_Response_T_Send_Dropped (Self : in out Instance; Arg : in Command_Response.T) is null;
   overriding procedure Data_Product_T_Send_Dropped (Self : in out Instance; Arg : in Data_Product.T) is null;
   overriding procedure Event_T_Send_Dropped (Self : in out Instance; Arg : in Event.T) is null;

   -- Command handlers:
   overriding function Set_State (Self : in out Instance; Arg : in Orbit_State.T) return Command_Execution_Status.E;
   overriding function Reset_Propagator (Self : in out Instance) return Command_Execution_Status.E;
   overriding procedure Invalid_Command (Self : in out Instance; Cmd : in Command.T; Errant_Field_Number : in Unsigned_32; Errant_Field : in Basic_Types.Poly_Type);

   -- Parameter handlers:
   overriding procedure Invalid_Parameter (Self : in out Instance; Par : in Parameter.T; Errant_Field_Number : in Unsigned_32; Errant_Field : in Basic_Types.Poly_Type);
   overriding procedure Update_Parameters_Action (Self : in out Instance);
   overriding function Validate_Parameters (
      Self : in out Instance;
      Orbit_Params : in Packed_Orbit_Params.U
   ) return Parameter_Validation_Status.E is (Parameter_Validation_Status.Valid);

end Component.Orbit_Propagator.Implementation;
