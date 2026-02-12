--------------------------------------------------------------------------------
-- Attitude_Estimator Component Implementation Body
--------------------------------------------------------------------------------

with Data_Product_Enums;

package body Component.Attitude_Estimator.Implementation is

   overriding procedure Init (Self : in out Instance; Dt : in Interfaces.IEEE_Float_32 := 0.1) is
   begin
      pragma Assert (Dt > 0.0, "Timestep must be positive.");
      Self.Dt := Dt;
      -- Identity quaternion:
      Self.Q1 := 0.0;
      Self.Q2 := 0.0;
      Self.Q3 := 0.0;
      Self.Q4 := 1.0;
   end Init;

   overriding procedure Set_Up (Self : in out Instance) is
      The_Time : constant Sys_Time.T := Self.Sys_Time_T_Get;
   begin
      Self.Data_Product_T_Send_If_Connected (Self.Data_Products.Estimated_Attitude (The_Time, (Q1 => Self.Q1, Q2 => Self.Q2, Q3 => Self.Q3, Q4 => Self.Q4)));
      Self.Data_Product_T_Send_If_Connected (Self.Data_Products.Estimated_Rate (The_Time, (X => 0.0, Y => 0.0, Z => 0.0)));
   end Set_Up;

   overriding procedure Tick_T_Recv_Sync (Self : in out Instance; Arg : in Tick.T) is
      use Data_Product_Enums.Data_Dependency_Status;
      Ignore : Tick.T renames Arg;
      The_Time : constant Sys_Time.T := Self.Sys_Time_T_Get;
      Gyro : Angular_Rate.T;
      Gyro_Status : constant E := Self.Get_Gyro_Rate (Value => Gyro, Stale_Reference => Arg.Time);
   begin
      if Gyro_Status = Success then
         -- Quaternion kinematic integration (first-order):
         -- q_dot = 0.5 * q * omega
         declare
            Wx : constant Interfaces.IEEE_Float_32 := Gyro.X;
            Wy : constant Interfaces.IEEE_Float_32 := Gyro.Y;
            Wz : constant Interfaces.IEEE_Float_32 := Gyro.Z;
            Half_Dt : constant Interfaces.IEEE_Float_32 := 0.5 * Self.Dt;
            -- Quaternion derivative:
            Dq1 : constant Interfaces.IEEE_Float_32 := Half_Dt * (-Wx * Self.Q2 - Wy * Self.Q3 - Wz * Self.Q4);
            Dq2 : constant Interfaces.IEEE_Float_32 := Half_Dt * ( Wx * Self.Q1 - Wz * Self.Q3 + Wy * Self.Q4);
            Dq3 : constant Interfaces.IEEE_Float_32 := Half_Dt * ( Wy * Self.Q1 + Wz * Self.Q2 - Wx * Self.Q4);
            Dq4 : constant Interfaces.IEEE_Float_32 := Half_Dt * ( Wz * Self.Q1 - Wy * Self.Q2 + Wx * Self.Q3);
            -- Integrated quaternion:
            Nq1 : Interfaces.IEEE_Float_32 := Self.Q1 + Dq1;
            Nq2 : Interfaces.IEEE_Float_32 := Self.Q2 + Dq2;
            Nq3 : Interfaces.IEEE_Float_32 := Self.Q3 + Dq3;
            Nq4 : Interfaces.IEEE_Float_32 := Self.Q4 + Dq4;
            -- Normalize:
            Norm : constant Interfaces.IEEE_Float_32 := Float_Math.Sqrt (Nq1 * Nq1 + Nq2 * Nq2 + Nq3 * Nq3 + Nq4 * Nq4);
         begin
            if Norm > 0.0 then
               Nq1 := Nq1 / Norm;
               Nq2 := Nq2 / Norm;
               Nq3 := Nq3 / Norm;
               Nq4 := Nq4 / Norm;
            end if;
            Self.Q1 := Nq1;
            Self.Q2 := Nq2;
            Self.Q3 := Nq3;
            Self.Q4 := Nq4;
         end;

         -- Publish estimated attitude and rate:
         Self.Data_Product_T_Send_If_Connected (Self.Data_Products.Estimated_Attitude (The_Time, (Q1 => Self.Q1, Q2 => Self.Q2, Q3 => Self.Q3, Q4 => Self.Q4)));
         Self.Data_Product_T_Send_If_Connected (Self.Data_Products.Estimated_Rate (The_Time, Gyro));
      else
         -- Gyro data stale, send event (but only occasionally to avoid flooding):
         Self.Event_T_Send_If_Connected (Self.Events.Gyro_Data_Stale (The_Time));
      end if;
   end Tick_T_Recv_Sync;

   overriding procedure Command_T_Recv_Sync (Self : in out Instance; Arg : in Command.T) is
      Stat : constant Command_Response_Status.E := Self.Execute_Command (Arg);
   begin
      Self.Command_Response_T_Send_If_Connected ((Source_Id => Arg.Header.Source_Id, Registration_Id => Self.Command_Reg_Id, Command_Id => Arg.Header.Id, Status => Stat));
   end Command_T_Recv_Sync;

   overriding function Reset_Attitude (Self : in out Instance) return Command_Execution_Status.E is
      use Command_Execution_Status;
      The_Time : constant Sys_Time.T := Self.Sys_Time_T_Get;
   begin
      Self.Q1 := 0.0;
      Self.Q2 := 0.0;
      Self.Q3 := 0.0;
      Self.Q4 := 1.0;
      Self.Data_Product_T_Send_If_Connected (Self.Data_Products.Estimated_Attitude (The_Time, (Q1 => Self.Q1, Q2 => Self.Q2, Q3 => Self.Q3, Q4 => Self.Q4)));
      Self.Event_T_Send_If_Connected (Self.Events.Attitude_Reset (The_Time));
      return Success;
   end Reset_Attitude;

   overriding procedure Invalid_Command (Self : in out Instance; Cmd : in Command.T; Errant_Field_Number : in Unsigned_32; Errant_Field : in Basic_Types.Poly_Type) is
   begin
      Self.Event_T_Send_If_Connected (Self.Events.Invalid_Command_Received (Self.Sys_Time_T_Get, (Id => Cmd.Header.Id, Errant_Field_Number => Errant_Field_Number, Errant_Field => Errant_Field)));
   end Invalid_Command;

   overriding procedure Invalid_Data_Dependency (Self : in out Instance; Id : in Data_Product_Types.Data_Product_Id; Ret : in Data_Product_Return.T) is
   begin
      null; -- Silently ignore invalid data dependencies.
   end Invalid_Data_Dependency;

end Component.Attitude_Estimator.Implementation;
