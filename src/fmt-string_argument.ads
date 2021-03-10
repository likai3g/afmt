with System;
package Fmt.String_Argument is


   function To_Argument (X : String) return Argument_Type'Class
      with Inline;

   function "&" (Args : Arguments; X : String) return Arguments
      with Inline;

private

   subtype UTF8_Character is String(1..6);

   type String_Argument_Type is new Argument_Type with record
      Value  : System.Address;
      Size   : Natural;
      Width  : Natural := 0;
      Align  : Text_Align := 'R';
      Fill   : UTF8_Character;
      Fill_L : Natural := 0; 
      Style  : Character := 'O';
   end record;

   overriding
   procedure Parse (
      Self : in out String_Argument_Type;
      Edit : String);

   overriding
   function Get_Length (Self : in out String_Argument_Type) return Natural;

   overriding
   procedure Put (
      Self : in out String_Argument_Type;
      Edit : String;
      To   : in out String);

end Fmt.String_Argument;


