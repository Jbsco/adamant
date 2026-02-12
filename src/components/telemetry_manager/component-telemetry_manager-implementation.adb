--------------------------------------------------------------------------------
-- Telemetry_Manager Component Implementation Body
--------------------------------------------------------------------------------

package body Component.Telemetry_Manager.Implementation is

   overriding procedure Init (Self : in out Instance; Queue_Size : in Natural := 10) is
   begin
      -- Initialize the base class queue:
      Self.Init_Base (Queue_Size => Queue_Size);
      Self.Forwarded_Count := 0;
      Self.Dropped_Count := 0;
   end Init;

   overriding procedure Set_Up (Self : in out Instance) is
      The_Time : constant Sys_Time.T := Self.Sys_Time_T_Get;
   begin
      Self.Data_Product_T_Send_If_Connected (Self.Data_Products.Products_Forwarded (The_Time, (Value => Unsigned_32 (Self.Forwarded_Count))));
      Self.Data_Product_T_Send_If_Connected (Self.Data_Products.Products_Dropped (The_Time, (Value => Unsigned_32 (Self.Dropped_Count))));
   end Set_Up;

   overriding procedure Data_Product_T_Recv_Async (Self : in out Instance; Arg : in Data_Product.T) is
      The_Time : constant Sys_Time.T := Self.Sys_Time_T_Get;
   begin
      -- Forward the data product downstream:
      Self.Data_Product_T_Send_If_Connected (Arg);
      Self.Forwarded_Count := Self.Forwarded_Count + 1;
      Self.Event_T_Send_If_Connected (Self.Events.Data_Product_Forwarded (The_Time));
      Self.Data_Product_T_Send_If_Connected (Self.Data_Products.Products_Forwarded (The_Time, (Value => Unsigned_32 (Self.Forwarded_Count))));
   end Data_Product_T_Recv_Async;

   overriding procedure Data_Product_T_Recv_Async_Dropped (Self : in out Instance; Arg : in Data_Product.T) is
      Ignore : Data_Product.T renames Arg;
      The_Time : constant Sys_Time.T := Self.Sys_Time_T_Get;
   begin
      Self.Dropped_Count := Self.Dropped_Count + 1;
      Self.Event_T_Send_If_Connected (Self.Events.Queue_Overflow (The_Time));
      Self.Data_Product_T_Send_If_Connected (Self.Data_Products.Products_Dropped (The_Time, (Value => Unsigned_32 (Self.Dropped_Count))));
   end Data_Product_T_Recv_Async_Dropped;

   overriding procedure Command_T_Recv_Sync (Self : in out Instance; Arg : in Command.T) is
      Stat : constant Command_Response_Status.E := Self.Execute_Command (Arg);
   begin
      Self.Command_Response_T_Send_If_Connected ((Source_Id => Arg.Header.Source_Id, Registration_Id => Self.Command_Reg_Id, Command_Id => Arg.Header.Id, Status => Stat));
   end Command_T_Recv_Sync;

   overriding function Reset_Count (Self : in out Instance) return Command_Execution_Status.E is
      use Command_Execution_Status;
      The_Time : constant Sys_Time.T := Self.Sys_Time_T_Get;
   begin
      Self.Forwarded_Count := 0;
      Self.Dropped_Count := 0;
      Self.Data_Product_T_Send_If_Connected (Self.Data_Products.Products_Forwarded (The_Time, (Value => 0)));
      Self.Data_Product_T_Send_If_Connected (Self.Data_Products.Products_Dropped (The_Time, (Value => 0)));
      return Success;
   end Reset_Count;

   overriding procedure Invalid_Command (Self : in out Instance; Cmd : in Command.T; Errant_Field_Number : in Unsigned_32; Errant_Field : in Basic_Types.Poly_Type) is
   begin
      Self.Event_T_Send_If_Connected (Self.Events.Invalid_Command_Received (Self.Sys_Time_T_Get, (Id => Cmd.Header.Id, Errant_Field_Number => Errant_Field_Number, Errant_Field => Errant_Field)));
   end Invalid_Command;

end Component.Telemetry_Manager.Implementation;
