--------------------------------------------------------------------------------
-- Power_Manager Component Implementation Body
--------------------------------------------------------------------------------

package body Component.Power_Manager.Implementation is

   overriding procedure Init (Self : in out Instance; Undervoltage_Limit : in Interfaces.Unsigned_16 := 2800; Overvoltage_Limit : in Interfaces.Unsigned_16 := 4200; Nominal_Voltage : in Interfaces.Unsigned_16 := 3700) is
   begin
      pragma Assert (Undervoltage_Limit < Nominal_Voltage, "Undervoltage must be below nominal.");
      pragma Assert (Nominal_Voltage < Overvoltage_Limit, "Nominal must be below overvoltage.");
      Self.Undervoltage_Limit := Undervoltage_Limit;
      Self.Overvoltage_Limit := Overvoltage_Limit;
      Self.Nominal_Voltage := Nominal_Voltage;
      Self.Battery_Mv := Nominal_Voltage;
      Self.Bus_State := Power_Manager_Enums.Power_Bus_State.Nominal;
      Self.Fault_Count := 0;
      Self.Forced := False;
   end Init;

   overriding procedure Set_Up (Self : in out Instance) is
      The_Time : constant Sys_Time.T := Self.Sys_Time_T_Get;
   begin
      Self.Data_Product_T_Send_If_Connected (Self.Data_Products.Power_Telemetry (The_Time, (Battery_Voltage => Self.Battery_Mv, Solar_Current => Self.Solar_Ma, Load_Current => Self.Load_Ma)));
      Self.Data_Product_T_Send_If_Connected (Self.Data_Products.Bus_State (The_Time, (State => Self.Bus_State)));
      Self.Data_Product_T_Send_If_Connected (Self.Data_Products.Fault_Count (The_Time, (Value => Self.Fault_Count)));
   end Set_Up;

   overriding procedure Tick_T_Recv_Sync (Self : in out Instance; Arg : in Tick.T) is
      use Power_Manager_Enums.Power_Bus_State;
      Ignore : Tick.T renames Arg;
      The_Time : constant Sys_Time.T := Self.Sys_Time_T_Get;
      Prev_State : constant E := Self.Bus_State;
   begin
      -- Publish power telemetry:
      Self.Data_Product_T_Send_If_Connected (Self.Data_Products.Power_Telemetry (The_Time, (Battery_Voltage => Self.Battery_Mv, Solar_Current => Self.Solar_Ma, Load_Current => Self.Load_Ma)));

      -- Check fault limits:
      if Self.Battery_Mv < Self.Undervoltage_Limit then
         Self.Fault_T_Send_If_Connected (Self.Faults.Undervoltage (The_Time, (Value => Self.Battery_Mv)));
         Self.Fault_Count := Self.Fault_Count + 1;
      end if;
      if Self.Battery_Mv > Self.Overvoltage_Limit then
         Self.Fault_T_Send_If_Connected (Self.Faults.Overvoltage (The_Time, (Value => Self.Battery_Mv)));
         Self.Fault_Count := Self.Fault_Count + 1;
      end if;

      -- State machine (only if not forced):
      if not Self.Forced then
         if Self.Battery_Mv < Self.Undervoltage_Limit then
            Self.Bus_State := Load_Shedding;
         elsif Self.Bus_State = Load_Shedding and then Self.Battery_Mv >= Self.Nominal_Voltage then
            Self.Bus_State := Nominal;
         end if;
      end if;

      -- Emit events on state transitions:
      if Self.Bus_State /= Prev_State then
         case Self.Bus_State is
            when Load_Shedding =>
               Self.Event_T_Send_If_Connected (Self.Events.Load_Shedding_Activated (The_Time, (Value => Self.Battery_Mv)));
            when Nominal =>
               Self.Event_T_Send_If_Connected (Self.Events.Load_Shedding_Cleared (The_Time, (Value => Self.Battery_Mv)));
            when Emergency_Shutdown =>
               null; -- Only reachable via force command
         end case;
         Self.Data_Product_T_Send_If_Connected (Self.Data_Products.Bus_State (The_Time, (State => Self.Bus_State)));
      end if;

      -- Publish fault count:
      Self.Data_Product_T_Send_If_Connected (Self.Data_Products.Fault_Count (The_Time, (Value => Self.Fault_Count)));
   end Tick_T_Recv_Sync;

   overriding procedure Command_T_Recv_Sync (Self : in out Instance; Arg : in Command.T) is
      Stat : constant Command_Response_Status.E := Self.Execute_Command (Arg);
   begin
      Self.Command_Response_T_Send_If_Connected ((Source_Id => Arg.Header.Source_Id, Registration_Id => Self.Command_Reg_Id, Command_Id => Arg.Header.Id, Status => Stat));
   end Command_T_Recv_Sync;

   overriding function Force_State (Self : in out Instance; Arg : in Packed_Power_Bus_State.T) return Command_Execution_Status.E is
      use Command_Execution_Status;
      The_Time : constant Sys_Time.T := Self.Sys_Time_T_Get;
   begin
      Self.Bus_State := Arg.State;
      Self.Forced := True;
      Self.Event_T_Send_If_Connected (Self.Events.State_Forced (The_Time, Arg));
      Self.Data_Product_T_Send_If_Connected (Self.Data_Products.Bus_State (The_Time, (State => Self.Bus_State)));
      return Success;
   end Force_State;

   overriding function Clear_Faults (Self : in out Instance) return Command_Execution_Status.E is
      use Command_Execution_Status;
      The_Time : constant Sys_Time.T := Self.Sys_Time_T_Get;
   begin
      Self.Fault_Count := 0;
      Self.Forced := False;
      Self.Bus_State := Power_Manager_Enums.Power_Bus_State.Nominal;
      Self.Event_T_Send_If_Connected (Self.Events.Faults_Cleared (The_Time));
      Self.Data_Product_T_Send_If_Connected (Self.Data_Products.Fault_Count (The_Time, (Value => Self.Fault_Count)));
      Self.Data_Product_T_Send_If_Connected (Self.Data_Products.Bus_State (The_Time, (State => Self.Bus_State)));
      return Success;
   end Clear_Faults;

   overriding procedure Invalid_Command (Self : in out Instance; Cmd : in Command.T; Errant_Field_Number : in Unsigned_32; Errant_Field : in Basic_Types.Poly_Type) is
   begin
      Self.Event_T_Send_If_Connected (Self.Events.Invalid_Command_Received (Self.Sys_Time_T_Get, (Id => Cmd.Header.Id, Errant_Field_Number => Errant_Field_Number, Errant_Field => Errant_Field)));
   end Invalid_Command;

end Component.Power_Manager.Implementation;
