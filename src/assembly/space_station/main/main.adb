with Ada.Text_IO; use Ada.Text_IO;
with Ada.Real_Time; use Ada.Real_Time;
with Ada.Exceptions; use Ada.Exceptions;
with Space_Station;

procedure Main is
   Wait_Time : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Microseconds (1000000);
   Start_Time : constant Ada.Real_Time.Time := Ada.Real_Time.Clock + Wait_Time;
begin
   -- Set up the assembly:
   Space_Station.Init_Base;
   Space_Station.Set_Id_Bases;
   Space_Station.Connect_Components;
   Space_Station.Init_Components;

   -- Start the assembly:
   Put_Line ("Starting Space Station assembly... Use Ctrl+C to exit.");
   delay until Start_Time;
   Space_Station.Start_Components;
   Space_Station.Set_Up_Components;

   -- Loop forever:
   loop
      delay until Clock + Milliseconds (500);
   end loop;

exception
   when Error : others =>
      Put ("Unhandled exception occurred in main: ");
      Put_Line (Exception_Information (Error));
end Main;
