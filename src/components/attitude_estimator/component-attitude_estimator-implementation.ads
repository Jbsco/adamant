--------------------------------------------------------------------------------
-- Attitude_Estimator Component Implementation Spec
--------------------------------------------------------------------------------

with Tick;
with Command;
with Ada.Numerics.Generic_Elementary_Functions;

-- Simple attitude estimator integrating gyro angular rates to propagate
-- a quaternion estimate.
package Component.Attitude_Estimator.Implementation is

   type Instance is new Attitude_Estimator.Base_Instance with private;

   overriding procedure Init (Self : in out Instance; Dt : in Interfaces.IEEE_Float_32 := 0.1);

private

   package Float_Math is new Ada.Numerics.Generic_Elementary_Functions (Interfaces.IEEE_Float_32);

   type Instance is new Attitude_Estimator.Base_Instance with record
      Dt : Interfaces.IEEE_Float_32 := 0.1;
      -- Attitude quaternion (scalar-last):
      Q1 : Interfaces.IEEE_Float_32 := 0.0;
      Q2 : Interfaces.IEEE_Float_32 := 0.0;
      Q3 : Interfaces.IEEE_Float_32 := 0.0;
      Q4 : Interfaces.IEEE_Float_32 := 1.0;
   end record;

   overriding procedure Set_Up (Self : in out Instance);

   overriding procedure Tick_T_Recv_Sync (Self : in out Instance; Arg : in Tick.T);
   overriding procedure Command_T_Recv_Sync (Self : in out Instance; Arg : in Command.T);

   overriding procedure Command_Response_T_Send_Dropped (Self : in out Instance; Arg : in Command_Response.T) is null;
   overriding procedure Data_Product_T_Send_Dropped (Self : in out Instance; Arg : in Data_Product.T) is null;
   overriding procedure Event_T_Send_Dropped (Self : in out Instance; Arg : in Event.T) is null;

   overriding function Reset_Attitude (Self : in out Instance) return Command_Execution_Status.E;
   overriding procedure Invalid_Command (Self : in out Instance; Cmd : in Command.T; Errant_Field_Number : in Unsigned_32; Errant_Field : in Basic_Types.Poly_Type);

   -- Data dependency override:
   overriding function Get_Data_Dependency (Self : in out Instance; Id : in Data_Product_Types.Data_Product_Id) return Data_Product_Return.T is (Self.Data_Product_Fetch_T_Request ((Id => Id)));
   overriding procedure Invalid_Data_Dependency (Self : in out Instance; Id : in Data_Product_Types.Data_Product_Id; Ret : in Data_Product_Return.T);

end Component.Attitude_Estimator.Implementation;
