--------------------------------------------------------------------------------
-- Watchdog_Manager Component Implementation Spec
--------------------------------------------------------------------------------

with Interfaces;
with Pet;
with Tick;

package Component.Watchdog_Manager.Implementation is

   type Instance is new Watchdog_Manager.Base_Instance with private;

   overriding procedure Init (Self : in out Instance; Timeout_Ticks : in Positive);

private

   Num_Sources : constant := 3;

   type Count_Array is array (Pet_T_Recv_Sync_Index) of Interfaces.Unsigned_32;
   type Tick_Array is array (Pet_T_Recv_Sync_Index) of Natural;

   type Instance is new Watchdog_Manager.Base_Instance with record
      Timeout_Ticks : Positive := 10;
      Last_Pet_Counts : Count_Array := [others => 0];
      Last_Pet_At : Tick_Array := [others => 0];
      Tick_Count : Natural := 0;
      Combined_Count : Interfaces.Unsigned_32 := 0;
   end record;

   overriding procedure Set_Up (Self : in out Instance) is null;

   overriding procedure Pet_T_Recv_Sync (Self : in out Instance; Index : in Pet_T_Recv_Sync_Index; Arg : in Pet.T);
   overriding procedure Tick_T_Recv_Sync (Self : in out Instance; Arg : in Tick.T);

   overriding procedure Pet_T_Send_Dropped (Self : in out Instance; Arg : in Pet.T) is null;
   overriding procedure Data_Product_T_Send_Dropped (Self : in out Instance; Arg : in Data_Product.T) is null;
   overriding procedure Event_T_Send_Dropped (Self : in out Instance; Arg : in Event.T) is null;
   overriding procedure Fault_T_Send_Dropped (Self : in out Instance; Arg : in Fault.T) is null;

end Component.Watchdog_Manager.Implementation;
