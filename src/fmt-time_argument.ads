with Ada.Calendar;
package Fmt.Time_Argument is


   function To_Argument (X : Ada.Calendar.Time) return Argument_Type'Class
      with Inline;


   function "&" (Args : Arguments; X : Ada.Calendar.Time) return Arguments
      with Inline;

private

   type Time_Argument_Type is new Placeholder_Argument_Type with record
      Value    : Ada.Calendar.Time;
   end record;

   overriding
   function Get_Placeholder_Width (
      Self : in out Time_Argument_Type;
      Name : Character)
      return Natural;

   overriding
   function Is_Valid_Placeholder (
      Self : Time_Argument_Type;
      Name : Character)
      return Boolean;

   overriding
   procedure Put_Placeholder (
      Self : in out Time_Argument_Type;
      Name : Character;
      To   : in out String);


end Fmt.Time_Argument;
