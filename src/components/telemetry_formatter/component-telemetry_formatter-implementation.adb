--------------------------------------------------------------------------------
-- Telemetry_Formatter Component Implementation Body
--------------------------------------------------------------------------------

with Data_Product_Return;
with Packet_Types;
with Data_Product_Enums;
use Data_Product_Enums.Fetch_Status;

package body Component.Telemetry_Formatter.Implementation is

   overriding procedure Init (Self : in out Instance; Packet_Period : in Positive) is
   begin
      Self.Packet_Period := Packet_Period;
   end Init;

   -- On each tick, check if it's time to emit a packet.
   overriding procedure Tick_T_Recv_Sync (Self : in out Instance; Arg : in Tick.T) is
      The_Time : constant Sys_Time.T := Self.Sys_Time_T_Get;
      Fetch_Result : Data_Product_Return.T;
      The_Packet : Packet.T;
      pragma Unreferenced (Arg);
   begin
      Self.Tick_Count := Self.Tick_Count + 1;

      -- Only emit packet at configured period
      if Self.Tick_Count mod Self.Packet_Period /= 0 then
         return;
      end if;

      -- Fetch data product ID 0 as an example
      Fetch_Result := Self.Data_Product_Fetch_T_Request ((Id => 0));

      -- If fetch succeeded, wrap it in a packet and send
      if Fetch_Result.The_Status = Success then
         The_Packet.Header.Time := The_Time;
         The_Packet.Header.Id := 1;
         The_Packet.Header.Sequence_Count := Packet_Types.Sequence_Count_Mod_Type (Self.Tick_Count mod 65536);
         The_Packet.Header.Buffer_Length := Fetch_Result.The_Data_Product.Header.Buffer_Length;
         -- Copy the data product buffer into the packet buffer
         The_Packet.Buffer (The_Packet.Buffer'First .. The_Packet.Buffer'First + Natural (The_Packet.Header.Buffer_Length) - 1) :=
            Fetch_Result.The_Data_Product.Buffer (Fetch_Result.The_Data_Product.Buffer'First .. Fetch_Result.The_Data_Product.Buffer'First + Natural (The_Packet.Header.Buffer_Length) - 1);
         Self.Packet_T_Send_If_Connected (The_Packet);
      end if;
   end Tick_T_Recv_Sync;

end Component.Telemetry_Formatter.Implementation;
