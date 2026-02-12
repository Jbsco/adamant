--------------------------------------------------------------------------------
-- Watchdog_Manager Component Implementation Body
--------------------------------------------------------------------------------

with Interfaces;
with Packed_U16;
with Packed_U32;

use type Interfaces.Unsigned_32;

package body Component.Watchdog_Manager.Implementation is

   overriding procedure Init (Self : in out Instance; Timeout_Ticks : in Positive) is
   begin
      Self.Timeout_Ticks := Timeout_Ticks;
   end Init;

   -- Store latest pet from each source.
   overriding procedure Pet_T_Recv_Sync (Self : in out Instance; Index : in Pet_T_Recv_Sync_Index; Arg : in Pet.T) is
   begin
      Self.Last_Pet_Counts (Index) := Arg.Count;
      Self.Last_Pet_At (Index) := Self.Tick_Count;
   end Pet_T_Recv_Sync;

   -- Check pet freshness and forward combined pet.
   overriding procedure Tick_T_Recv_Sync (Self : in out Instance; Arg : in Tick.T) is
      The_Time : constant Sys_Time.T := Self.Sys_Time_T_Get;
      All_Healthy : Boolean := True;
      pragma Unreferenced (Arg);
   begin
      Self.Tick_Count := Self.Tick_Count + 1;

      -- Check each source for timeout
      for I in Self.Last_Pet_At'Range loop
         if Self.Tick_Count - Self.Last_Pet_At (I) > Self.Timeout_Ticks then
            All_Healthy := False;
            Self.Event_T_Send_If_Connected (Self.Events.Pet_Timeout (The_Time,
               (Value => Interfaces.Unsigned_16 (I))));
            Self.Fault_T_Send_If_Connected (Self.Faults.Rate_Group_Timeout (The_Time,
               (Value => Interfaces.Unsigned_16 (I))));
         end if;
      end loop;

      -- Forward combined pet if all healthy
      if All_Healthy then
         Self.Combined_Count := Self.Combined_Count + 1;
         Self.Pet_T_Send_If_Connected ((Count => Self.Combined_Count));
         Self.Data_Product_T_Send_If_Connected (Self.Data_Products.Combined_Pet_Count (The_Time,
            (Value => Self.Combined_Count)));
      end if;
   end Tick_T_Recv_Sync;

end Component.Watchdog_Manager.Implementation;
