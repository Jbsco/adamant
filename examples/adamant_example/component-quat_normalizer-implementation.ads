--------------------------------------------------------------------------------
-- Quat_Normalizer Component Implementation Spec
--------------------------------------------------------------------------------

-- Includes:
with Quaternion;
with Quat_Norm_Algorithm_C; use Quat_Norm_Algorithm_C;
with Interfaces;

-- Wraps QuatNorm algorithm to normalize quaternions with validation
package Component.Quat_Normalizer.Implementation is

   -- The component class instance record:
   type Instance is new Quat_Normalizer.Base_Instance with private;

   --------------------------------------------------
   -- Subprogram for implementation init method:
   --------------------------------------------------
   -- Initialize the quaternion normalizer algorithm
   overriding procedure Init (Self : in out Instance);
   
   --------------------------------------------------
   -- Subprogram for implementation destroy method:
   --------------------------------------------------
   not overriding procedure Destroy (Self : in out Instance);

private

   -- The component class instance record:
   type Instance is new Quat_Normalizer.Base_Instance with record
      Alg : Quat_Norm_Algorithm_Access := null;
      Normalization_Count : Interfaces.Unsigned_32 := 0;
   end record;

   ---------------------------------------
   -- Set Up Procedure
   ---------------------------------------
   -- Null method which can be implemented to provide some component
   -- set up code. This method is generally called by the assembly
   -- main.adb after all component initialization and tasks have been started.
   -- Some activities need to only be run once at startup, but cannot be run
   -- safely until everything is up and running, ie. command registration, initial
   -- data product updates. This procedure should be implemented to do these things
   -- if necessary.
   overriding procedure Set_Up (Self : in out Instance) is null;

   ---------------------------------------
   -- Invokee connector primitives:
   ---------------------------------------
   -- Tick connector - receives quaternion to normalize
   overriding procedure Quaternion_Recv_Sync (Self : in out Instance; Arg : in Quaternion.T);

   ---------------------------------------
   -- Invoker connector primitives:
   ---------------------------------------
   -- This procedure is called when a Quaternion_Result_Send message is dropped due to a full queue.
   overriding procedure Quaternion_Result_Send_Dropped (Self : in out Instance; Arg : in Quat_Norm_Result.T) is null;
   -- This procedure is called when a Event_T_Send message is dropped due to a full queue.
   overriding procedure Event_T_Send_Dropped (Self : in out Instance; Arg : in Event.T) is null;
   -- This procedure is called when a Data_Product_T_Send message is dropped due to a full queue.
   overriding procedure Data_Product_T_Send_Dropped (Self : in out Instance; Arg : in Data_Product.T) is null;

end Component.Quat_Normalizer.Implementation;