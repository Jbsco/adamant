--------------------------------------------------------------------------------
-- Telemetry_Formatter Tests Body
--------------------------------------------------------------------------------

with AUnit.Assertions; use AUnit.Assertions;
with Tick;
with Packet;
with Packet_Types; use type Packet_Types.Sequence_Count_Mod_Type;

package body Telemetry_Formatter_Tests.Implementation is

   The_Tick : constant Tick.T := (Time => (0, 0), Count => 1);

   overriding procedure Set_Up_Test (Self : in out Instance) is
   begin
      Self.Tester.Init_Base;
      Self.Tester.Connect;
      Self.Tester.Component_Instance.Init (Packet_Period => 2);
      Self.Tester.Component_Instance.Set_Up;
   end Set_Up_Test;

   overriding procedure Tear_Down_Test (Self : in out Instance) is
   begin
      Self.Tester.Final_Base;
   end Tear_Down_Test;

   -- Verify packet emitted at the configured period (every 2 ticks)
   overriding procedure Test_Packet_Emission (Self : in out Instance) is
      T : Component.Telemetry_Formatter.Implementation.Tester.Instance_Access renames Self.Tester;
   begin
      -- Tick 1: no packet (period=2, tick_count=1, 1 mod 2 /= 0)
      T.Tick_T_Send (The_Tick);
      Assert (T.Packet_T_Recv_Sync_History.Get_Count = 0, "No packet on tick 1.");

      -- Tick 2: packet emitted (tick_count=2, 2 mod 2 = 0)
      T.Tick_T_Send (The_Tick);
      Assert (T.Packet_T_Recv_Sync_History.Get_Count = 1, "Packet on tick 2.");
   end Test_Packet_Emission;

   -- Verify no packet before period
   overriding procedure Test_No_Packet_Before_Period (Self : in out Instance) is
      T : Component.Telemetry_Formatter.Implementation.Tester.Instance_Access renames Self.Tester;
   begin
      T.Tick_T_Send (The_Tick);
      Assert (T.Packet_T_Recv_Sync_History.Get_Count = 0, "No packet before period.");
      Assert (T.Data_Product_Fetch_T_Service_History.Get_Count = 0, "No fetch before period.");
   end Test_No_Packet_Before_Period;

   -- Verify sequence count increments
   overriding procedure Test_Sequence_Count (Self : in out Instance) is
      T : Component.Telemetry_Formatter.Implementation.Tester.Instance_Access renames Self.Tester;
      Pkt_1 : Packet.T;
      Pkt_2 : Packet.T;
   begin
      -- Generate two packets (ticks 1-4, packets at ticks 2 and 4)
      for I in 1 .. 4 loop
         T.Tick_T_Send (The_Tick);
      end loop;
      Assert (T.Packet_T_Recv_Sync_History.Get_Count = 2, "Two packets after 4 ticks.");

      Pkt_1 := T.Packet_T_Recv_Sync_History.Get (1);
      Pkt_2 := T.Packet_T_Recv_Sync_History.Get (2);

      -- Sequence counts should differ (based on tick_count mod 65536)
      Assert (Pkt_1.Header.Sequence_Count /= Pkt_2.Header.Sequence_Count,
              "Sequence counts should differ.");
   end Test_Sequence_Count;

end Telemetry_Formatter_Tests.Implementation;
