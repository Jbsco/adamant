--------------------------------------------------------------------------------
-- Mode_Manager Component Implementation Body
--------------------------------------------------------------------------------

with Mode_Manager_Enums;
use Mode_Manager_Enums.System_Mode;
with Packed_Mode_Transition;
with Packed_U16;

package body Component.Mode_Manager.Implementation is

   use type Interfaces.Unsigned_16;
   use type Mode_Manager_Enums.System_Mode.E;

   procedure Do_Transition (Self : in out Instance; To_Mode : in Mode_Manager_Enums.System_Mode.E) is
      The_Time : constant Sys_Time.T := Self.Sys_Time_T_Get;
      From_Mode : constant Mode_Manager_Enums.System_Mode.E := Self.Current_Mode;
   begin
      Self.Current_Mode := To_Mode;
      Self.Transition_Count := Self.Transition_Count + 1;
      Self.Event_T_Send_If_Connected (Self.Events.Mode_Transition (The_Time,
         (From_Mode => From_Mode, To_Mode => To_Mode)));
      Self.Data_Product_T_Send_If_Connected (Self.Data_Products.Current_Mode (The_Time,
         (Target_Mode => Self.Current_Mode)));
      Self.Data_Product_T_Send_If_Connected (Self.Data_Products.Transition_Count (The_Time,
         (Value => Self.Transition_Count)));
   end Do_Transition;

   overriding procedure Init (Self : in out Instance; Initial_Mode : in Mode_Manager_Enums.System_Mode.E := Safe) is
   begin
      Self.Current_Mode := Initial_Mode;
      Self.Transition_Count := 0;
   end Init;

   overriding procedure Set_Up (Self : in out Instance) is
      The_Time : constant Sys_Time.T := Self.Sys_Time_T_Get;
   begin
      Self.Data_Product_T_Send_If_Connected (Self.Data_Products.Current_Mode (The_Time,
         (Target_Mode => Self.Current_Mode)));
      Self.Data_Product_T_Send_If_Connected (Self.Data_Products.Transition_Count (The_Time,
         (Value => Self.Transition_Count)));
   end Set_Up;

   overriding procedure Tick_T_Recv_Sync (Self : in out Instance; Arg : in Tick.T) is
      pragma Unreferenced (Arg);
      The_Time : constant Sys_Time.T := Self.Sys_Time_T_Get;
   begin
      -- Periodically publish current mode
      Self.Data_Product_T_Send_If_Connected (Self.Data_Products.Current_Mode (The_Time,
         (Target_Mode => Self.Current_Mode)));
   end Tick_T_Recv_Sync;

   overriding procedure Command_T_Recv_Sync (Self : in out Instance; Arg : in Command.T) is
      Stat : constant Command_Response_Status.E := Self.Execute_Command (Arg);
   begin
      Self.Command_Response_T_Send_If_Connected ((Source_Id => Arg.Header.Source_Id, Registration_Id => Self.Command_Reg_Id, Command_Id => Arg.Header.Id, Status => Stat));
   end Command_T_Recv_Sync;

   overriding function Set_Mode (Self : in out Instance; Arg : in Packed_Mode_Cmd_Type.T) return Command_Execution_Status.E is
      use Command_Execution_Status;
   begin
      if Arg.Target_Mode = Self.Current_Mode then
         return Success;  -- Already in requested mode
      end if;

      if Allowed (Self.Current_Mode, Arg.Target_Mode) then
         Self.Do_Transition (Arg.Target_Mode);
         return Success;
      else
         Self.Event_T_Send_If_Connected (Self.Events.Mode_Transition_Rejected (Self.Sys_Time_T_Get,
            (From_Mode => Self.Current_Mode, To_Mode => Arg.Target_Mode)));
         return Failure;
      end if;
   end Set_Mode;

   overriding function Force_Safe_Mode (Self : in out Instance) return Command_Execution_Status.E is
      use Command_Execution_Status;
   begin
      if Self.Current_Mode /= Safe then
         Self.Do_Transition (Safe);
         Self.Event_T_Send_If_Connected (Self.Events.Forced_Safe_Mode (Self.Sys_Time_T_Get));
      end if;
      return Success;
   end Force_Safe_Mode;

   overriding procedure Invalid_Command (Self : in out Instance; Cmd : in Command.T; Errant_Field_Number : in Unsigned_32; Errant_Field : in Basic_Types.Poly_Type) is
   begin
      Self.Event_T_Send_If_Connected (Self.Events.Invalid_Command_Received (Self.Sys_Time_T_Get,
         (Id => Cmd.Header.Id, Errant_Field_Number => Errant_Field_Number, Errant_Field => Errant_Field)));
   end Invalid_Command;

end Component.Mode_Manager.Implementation;
