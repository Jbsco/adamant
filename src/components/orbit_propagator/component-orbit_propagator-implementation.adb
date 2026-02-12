--------------------------------------------------------------------------------
-- Orbit_Propagator Component Implementation Body
--------------------------------------------------------------------------------

package body Component.Orbit_Propagator.Implementation is

   overriding procedure Init (Self : in out Instance; Dt : in Interfaces.IEEE_Float_32 := 1.0) is
   begin
      pragma Assert (Dt > 0.0, "Timestep must be positive.");
      Self.Dt := Dt;
      Self.Px := 0.0; Self.Py := 0.0; Self.Pz := 0.0;
      Self.Vx := 0.0; Self.Vy := 0.0; Self.Vz := 0.0;
      Self.Prop_Count := 0;
   end Init;

   overriding procedure Set_Up (Self : in out Instance) is
      The_Time : constant Sys_Time.T := Self.Sys_Time_T_Get;
   begin
      Self.Data_Product_T_Send_If_Connected (Self.Data_Products.Current_State (The_Time, (Pos_X => Self.Px, Pos_Y => Self.Py, Pos_Z => Self.Pz, Vel_X => Self.Vx, Vel_Y => Self.Vy, Vel_Z => Self.Vz)));
      Self.Data_Product_T_Send_If_Connected (Self.Data_Products.Propagation_Count (The_Time, (Value => Unsigned_32 (Self.Prop_Count))));
   end Set_Up;

   -- Two-body gravitational acceleration: a = -mu * r / |r|^3
   procedure Gravity_Accel (Mu : Interfaces.IEEE_Float_32; Px, Py, Pz : Interfaces.IEEE_Float_32; Ax, Ay, Az : out Interfaces.IEEE_Float_32) is
      R2 : constant Interfaces.IEEE_Float_32 := Px * Px + Py * Py + Pz * Pz;
      R : constant Interfaces.IEEE_Float_32 := Float_Math.Sqrt (R2);
      R3 : Interfaces.IEEE_Float_32;
   begin
      if R > 0.001 then
         R3 := R * R2;
         Ax := -Mu * Px / R3;
         Ay := -Mu * Py / R3;
         Az := -Mu * Pz / R3;
      else
         -- Avoid singularity at center:
         Ax := 0.0; Ay := 0.0; Az := 0.0;
      end if;
   end Gravity_Accel;

   overriding procedure Tick_T_Recv_Sync (Self : in out Instance; Arg : in Tick.T) is
      Ignore : Tick.T renames Arg;
      The_Time : constant Sys_Time.T := Self.Sys_Time_T_Get;
      Mu : constant Interfaces.IEEE_Float_32 := Self.Orbit_Params.Mu;
      Dt : constant Interfaces.IEEE_Float_32 := Self.Dt;
      Half_Dt : constant Interfaces.IEEE_Float_32 := 0.5 * Dt;
      Ax, Ay, Az : Interfaces.IEEE_Float_32;
      -- RK4 intermediate states:
      Px1, Py1, Pz1, Vx1, Vy1, Vz1 : Interfaces.IEEE_Float_32;
      Px2, Py2, Pz2, Vx2, Vy2, Vz2 : Interfaces.IEEE_Float_32;
      Px3, Py3, Pz3, Vx3, Vy3, Vz3 : Interfaces.IEEE_Float_32;
      Ax1, Ay1, Az1, Ax2, Ay2, Az2 : Interfaces.IEEE_Float_32;
      Ax3, Ay3, Az3, Ax4, Ay4, Az4 : Interfaces.IEEE_Float_32;
   begin
      -- Apply any staged parameter updates:
      Self.Update_Parameters;

      -- RK4 integration of two-body problem:
      -- k1:
      Gravity_Accel (Mu, Self.Px, Self.Py, Self.Pz, Ax1, Ay1, Az1);
      -- k2:
      Px1 := Self.Px + Half_Dt * Self.Vx;
      Py1 := Self.Py + Half_Dt * Self.Vy;
      Pz1 := Self.Pz + Half_Dt * Self.Vz;
      Vx1 := Self.Vx + Half_Dt * Ax1;
      Vy1 := Self.Vy + Half_Dt * Ay1;
      Vz1 := Self.Vz + Half_Dt * Az1;
      Gravity_Accel (Mu, Px1, Py1, Pz1, Ax2, Ay2, Az2);
      -- k3:
      Px2 := Self.Px + Half_Dt * Vx1;
      Py2 := Self.Py + Half_Dt * Vy1;
      Pz2 := Self.Pz + Half_Dt * Vz1;
      Vx2 := Self.Vx + Half_Dt * Ax2;
      Vy2 := Self.Vy + Half_Dt * Ay2;
      Vz2 := Self.Vz + Half_Dt * Az2;
      Gravity_Accel (Mu, Px2, Py2, Pz2, Ax3, Ay3, Az3);
      -- k4:
      Px3 := Self.Px + Dt * Vx2;
      Py3 := Self.Py + Dt * Vy2;
      Pz3 := Self.Pz + Dt * Vz2;
      Vx3 := Self.Vx + Dt * Ax3;
      Vy3 := Self.Vy + Dt * Ay3;
      Vz3 := Self.Vz + Dt * Az3;
      Gravity_Accel (Mu, Px3, Py3, Pz3, Ax4, Ay4, Az4);

      -- Update state:
      Self.Px := Self.Px + (Dt / 6.0) * (Self.Vx + 2.0 * Vx1 + 2.0 * Vx2 + Vx3);
      Self.Py := Self.Py + (Dt / 6.0) * (Self.Vy + 2.0 * Vy1 + 2.0 * Vy2 + Vy3);
      Self.Pz := Self.Pz + (Dt / 6.0) * (Self.Vz + 2.0 * Vz1 + 2.0 * Vz2 + Vz3);
      Self.Vx := Self.Vx + (Dt / 6.0) * (Ax1 + 2.0 * Ax2 + 2.0 * Ax3 + Ax4);
      Self.Vy := Self.Vy + (Dt / 6.0) * (Ay1 + 2.0 * Ay2 + 2.0 * Ay3 + Ay4);
      Self.Vz := Self.Vz + (Dt / 6.0) * (Az1 + 2.0 * Az2 + 2.0 * Az3 + Az4);
      Self.Prop_Count := Self.Prop_Count + 1;

      -- Publish state:
      Self.Data_Product_T_Send_If_Connected (Self.Data_Products.Current_State (The_Time, (Pos_X => Self.Px, Pos_Y => Self.Py, Pos_Z => Self.Pz, Vel_X => Self.Vx, Vel_Y => Self.Vy, Vel_Z => Self.Vz)));
      Self.Data_Product_T_Send_If_Connected (Self.Data_Products.Propagation_Count (The_Time, (Value => Unsigned_32 (Self.Prop_Count))));
   end Tick_T_Recv_Sync;

   overriding procedure Command_T_Recv_Sync (Self : in out Instance; Arg : in Command.T) is
      Stat : constant Command_Response_Status.E := Self.Execute_Command (Arg);
   begin
      Self.Command_Response_T_Send_If_Connected ((Source_Id => Arg.Header.Source_Id, Registration_Id => Self.Command_Reg_Id, Command_Id => Arg.Header.Id, Status => Stat));
   end Command_T_Recv_Sync;

   overriding procedure Parameter_Update_T_Modify (Self : in out Instance; Arg : in out Parameter_Update.T) is
   begin
      Self.Process_Parameter_Update (Arg);
   end Parameter_Update_T_Modify;

   overriding function Set_State (Self : in out Instance; Arg : in Orbit_State.T) return Command_Execution_Status.E is
      use Command_Execution_Status;
      The_Time : constant Sys_Time.T := Self.Sys_Time_T_Get;
   begin
      Self.Px := Arg.Pos_X; Self.Py := Arg.Pos_Y; Self.Pz := Arg.Pos_Z;
      Self.Vx := Arg.Vel_X; Self.Vy := Arg.Vel_Y; Self.Vz := Arg.Vel_Z;
      Self.Event_T_Send_If_Connected (Self.Events.State_Updated (The_Time, Arg));
      Self.Data_Product_T_Send_If_Connected (Self.Data_Products.Current_State (The_Time, (Pos_X => Self.Px, Pos_Y => Self.Py, Pos_Z => Self.Pz, Vel_X => Self.Vx, Vel_Y => Self.Vy, Vel_Z => Self.Vz)));
      return Success;
   end Set_State;

   overriding function Reset_Propagator (Self : in out Instance) return Command_Execution_Status.E is
      use Command_Execution_Status;
      The_Time : constant Sys_Time.T := Self.Sys_Time_T_Get;
   begin
      Self.Px := 0.0; Self.Py := 0.0; Self.Pz := 0.0;
      Self.Vx := 0.0; Self.Vy := 0.0; Self.Vz := 0.0;
      Self.Prop_Count := 0;
      Self.Data_Product_T_Send_If_Connected (Self.Data_Products.Current_State (The_Time, (Pos_X => 0.0, Pos_Y => 0.0, Pos_Z => 0.0, Vel_X => 0.0, Vel_Y => 0.0, Vel_Z => 0.0)));
      Self.Data_Product_T_Send_If_Connected (Self.Data_Products.Propagation_Count (The_Time, (Value => 0)));
      return Success;
   end Reset_Propagator;

   overriding procedure Invalid_Command (Self : in out Instance; Cmd : in Command.T; Errant_Field_Number : in Unsigned_32; Errant_Field : in Basic_Types.Poly_Type) is
   begin
      Self.Event_T_Send_If_Connected (Self.Events.Invalid_Command_Received (Self.Sys_Time_T_Get, (Id => Cmd.Header.Id, Errant_Field_Number => Errant_Field_Number, Errant_Field => Errant_Field)));
   end Invalid_Command;

   overriding procedure Invalid_Parameter (Self : in out Instance; Par : in Parameter.T; Errant_Field_Number : in Unsigned_32; Errant_Field : in Basic_Types.Poly_Type) is
      Ignore_Par : Parameter.T renames Par;
      Ignore_Field : Unsigned_32 renames Errant_Field_Number;
      Ignore_Poly : Basic_Types.Poly_Type renames Errant_Field;
   begin
      null; -- Silently ignore invalid parameters.
   end Invalid_Parameter;

   overriding procedure Update_Parameters_Action (Self : in out Instance) is
      The_Time : constant Sys_Time.T := Self.Sys_Time_T_Get;
   begin
      -- Emit event when parameters change:
      Self.Event_T_Send_If_Connected (Self.Events.Parameters_Updated (The_Time, Packed_Orbit_Params.Pack (Self.Orbit_Params)));
   end Update_Parameters_Action;

end Component.Orbit_Propagator.Implementation;
