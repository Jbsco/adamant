--------------------------------------------------------------------------------
-- Quat_Normalizer Component Implementation Body
--------------------------------------------------------------------------------

with Interfaces.C;
with Sys_Time;

package body Component.Quat_Normalizer.Implementation is

   --------------------------------------------------
   -- Subprogram for implementation init method:
   --------------------------------------------------
   -- Initialize the quaternion normalizer algorithm
   overriding procedure Init (Self : in out Instance) is
   begin
      -- Create algorithm instance
      Self.Alg := Create;
   end Init;

   --------------------------------------------------
   -- Subprogram for implementation destroy method:
   --------------------------------------------------
   not overriding procedure Destroy (Self : in out Instance) is
   begin
      -- Clean up algorithm instance
      if Self.Alg /= null then
         Destroy (Self.Alg);
      end if;
   end Destroy;

   ---------------------------------------
   -- Invokee connector primitives:
   ---------------------------------------
   -- Tick connector - receives quaternion to normalize
   overriding procedure Quaternion_Recv_Sync (Self : in out Instance; Arg : in Quaternion.T) is
      use Interfaces.C;
      
      -- Convert from framework quaternion (scalar-last: Q1,Q2,Q3,Q4) to algorithm format (scalar-first: w,x,y,z)  
      Input_C : aliased constant Quaternion_C_Type := (
         Q => [0 => C_float (Arg.Q4), -- Q4 (scalar) -> w
               1 => C_float (Arg.Q1), -- Q1 (vector x) -> x
               2 => C_float (Arg.Q2), -- Q2 (vector y) -> y  
               3 => C_float (Arg.Q3)]); -- Q3 (vector z) -> z
      
      Result_C : constant Quat_Result_C_Type := Normalize (Self.Alg, Input_C'Unchecked_Access);
      
      -- Get current timestamp
      Time_Now : constant Sys_Time.T := Self.Sys_Time_T_Get;
   begin
      -- Check if normalization was successful (convert C_bool to Boolean)
      if Result_C.Valid = Interfaces.C.C_bool'Val (1) then
         -- Convert result back to framework quaternion convention (scalar-last)
         declare
            Result_Quat : constant Quat_Norm_Result.T := (
               Q_Out_W => Short_Float (Result_C.Q_Out (0)), -- w -> W  
               Q_Out_X => Short_Float (Result_C.Q_Out (1)), -- x -> X
               Q_Out_Y => Short_Float (Result_C.Q_Out (2)), -- y -> Y
               Q_Out_Z => Short_Float (Result_C.Q_Out (3)), -- z -> Z
               Magnitude => Short_Float (Result_C.Magnitude),
               Valid => Boolean'Val (Interfaces.C.C_bool'Pos (Result_C.Valid)));
         begin
            -- Send normalized quaternion result
            Self.Quaternion_Result_Send (Result_Quat);
            
            -- Increment and send normalization count data product
            Self.Normalization_Count := Self.Normalization_Count + 1;
            Self.Data_Product_T_Send_If_Connected (
               Self.Data_Products.Normalization_Count (Time_Now, 
                  (Value => Self.Normalization_Count)));
         end;
      else
         -- Send invalid quaternion event
         Self.Event_T_Send_If_Connected (
            Self.Events.Invalid_Quaternion (Time_Now, Arg));
      end if;
   end Quaternion_Recv_Sync;

end Component.Quat_Normalizer.Implementation;