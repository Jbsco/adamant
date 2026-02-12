--------------------------------------------------------------------------------
-- Nav_Aggregate_Practice Component Implementation Body
--------------------------------------------------------------------------------

with Data_Product_Enums; use Data_Product_Enums;
with Nav_Att;
with Nav_Trans;
with Nav_Aggregate_Output;

package body Component.Nav_Aggregate_Practice.Implementation is

   use type Data_Dependency_Status.E;

   -- Utility function to check if data dependency status indicates success
   function Is_Dep_Status_Success (Status : Data_Dependency_Status.E) return Boolean is
   begin
      return Status = Data_Dependency_Status.Success;
   end Is_Dep_Status_Success;

   ---------------------------------------
   -- Invokee connector primitives:
   ---------------------------------------
   -- Run algorithm on tick.
   overriding procedure Tick_T_Recv_Sync (Self : in out Instance; Arg : in Tick.T) is
      use Data_Product_Enums.Data_Dependency_Status;
      
      -- Data dependencies (fetched every tick)
      Primary_Att_Nav : Nav_Att.T;
      Secondary_Att_Nav : Nav_Att.T;
      Primary_Trans_Nav : Nav_Trans.T;
      Secondary_Trans_Nav : Nav_Trans.T;
      
      -- Status of data dependency fetches
      Primary_Att_Status : constant Data_Dependency_Status.E :=
         Self.Get_Primary_Attitude_Nav (Value => Primary_Att_Nav, Stale_Reference => Arg.Time);
      Secondary_Att_Status : constant Data_Dependency_Status.E :=
         Self.Get_Secondary_Attitude_Nav (Value => Secondary_Att_Nav, Stale_Reference => Arg.Time);
      Primary_Trans_Status : constant Data_Dependency_Status.E :=
         Self.Get_Primary_Translational_Nav (Value => Primary_Trans_Nav, Stale_Reference => Arg.Time);
      Secondary_Trans_Status : constant Data_Dependency_Status.E :=
         Self.Get_Secondary_Translational_Nav (Value => Secondary_Trans_Nav, Stale_Reference => Arg.Time);
   begin
      -- Update parameters if needed (applies staged parameter changes)
      Self.Update_Parameters;
      
      -- Only proceed if we have valid data dependencies
      if Is_Dep_Status_Success (Primary_Att_Status) and then
         Is_Dep_Status_Success (Primary_Trans_Status) then
         
         declare
            -- Create aggregated output using parameters to select sources
            Aggregated_Output : Nav_Aggregate_Output.T;
         begin
            -- Use primary or secondary attitude based on parameter configuration
            if Self.Att_Idx.Value = 0 then
               Aggregated_Output.Nav_Att_Out := Primary_Att_Nav;
            elsif Is_Dep_Status_Success (Secondary_Att_Status) then
               Aggregated_Output.Nav_Att_Out := Secondary_Att_Nav;
            else
               Aggregated_Output.Nav_Att_Out := Primary_Att_Nav; -- Fallback
            end if;
            
            -- Use primary or secondary translational based on parameter configuration
            if Self.Pos_Idx.Value = 0 then
               Aggregated_Output.Nav_Trans_Out := Primary_Trans_Nav;
            elsif Is_Dep_Status_Success (Secondary_Trans_Status) then
               Aggregated_Output.Nav_Trans_Out := Secondary_Trans_Nav;
            else
               Aggregated_Output.Nav_Trans_Out := Primary_Trans_Nav; -- Fallback
            end if;
            
            -- Send aggregated result as data product
            Self.Data_Product_T_Send_If_Connected (
               Self.Data_Products.Aggregated_Nav_State (Arg.Time, Aggregated_Output)
            );
         end;
      end if;
   end Tick_T_Recv_Sync;

   -- The parameter update connector.
   overriding procedure Parameter_Update_T_Modify (Self : in out Instance; Arg : in out Parameter_Update.T) is
   begin
      -- Process the parameter update, staging or fetching parameters as requested.
      Self.Process_Parameter_Update (Arg);
   end Parameter_Update_T_Modify;

   -----------------------------------------------
   -- Parameter handlers:
   -----------------------------------------------
   -- Description:
   --    Configuration parameters for nav aggregate algorithm.
   -- Invalid Parameter handler. This procedure is called when a parameter's type is found to be invalid:
   overriding procedure Invalid_Parameter (Self : in out Instance; Par : in Parameter.T; Errant_Field_Number : in Unsigned_32; Errant_Field : in Basic_Types.Poly_Type) is
   begin
      -- TODO: Perform action to handle an invalid parameter.
      -- Example:
      -- -- Throw event:
      -- Self.Event_T_Send_If_Connected (Self.Events.Invalid_Parameter_Received (
      --    Self.Sys_Time_T_Get,
      --    (Id => Par.Header.Id, Errant_Field_Number => Errant_Field_Number, Errant_Field => Errant_Field)
      -- ));
      null;
   end Invalid_Parameter;

   -----------------------------------------------
   -- Data dependency handlers:
   -----------------------------------------------
   -- Description:
   --    Data dependencies for nav aggregate algorithm.
   -- Invalid data dependency handler. This procedure is called when a data dependency's id or length are found to be invalid:
   overriding procedure Invalid_Data_Dependency (Self : in out Instance; Id : in Data_Product_Types.Data_Product_Id; Ret : in Data_Product_Return.T) is
      pragma Annotate (GNATSAS, Intentional, "subp always fails", "intentional assertion");
   begin
      -- Safety-critical wrapper: silent failure with assertion
      pragma Assert (False);
   end Invalid_Data_Dependency;

end Component.Nav_Aggregate_Practice.Implementation;
