--------------------------------------------------------------------------------
-- Telemetry_Formatter Component Implementation Spec
--------------------------------------------------------------------------------

with Tick;

package Component.Telemetry_Formatter.Implementation is

   type Instance is new Telemetry_Formatter.Base_Instance with private;

   overriding procedure Init (Self : in out Instance; Packet_Period : in Positive);

private

   type Instance is new Telemetry_Formatter.Base_Instance with record
      Packet_Period : Positive := 1;
      Tick_Count : Natural := 0;
   end record;

   overriding procedure Set_Up (Self : in out Instance) is null;

   overriding procedure Tick_T_Recv_Sync (Self : in out Instance; Arg : in Tick.T);

   overriding procedure Packet_T_Send_Dropped (Self : in out Instance; Arg : in Packet.T) is null;
   overriding procedure Event_T_Send_Dropped (Self : in out Instance; Arg : in Event.T) is null;
   overriding procedure Data_Product_T_Send_Dropped (Self : in out Instance; Arg : in Data_Product.T) is null;

end Component.Telemetry_Formatter.Implementation;
