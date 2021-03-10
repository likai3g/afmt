generic
type Fixed_Point_Type is delta <> digits <>;
package Fmt.Generic_Decimal_Fixed_Point_Argument is


   function To_Argument (X : Fixed_Point_Type) return Argument_Type'Class
      with Inline;

   function "&" (Args : Arguments; X : Fixed_Point_Type) return Arguments
      with Inline;


private


   type Fixed_Point_Argument_Type is new Argument_Type with record
      Value : Fixed_Point_Type;
      Width : Natural := 0;
      Fill  : Character := ' ';
      Fore  : Natural := Fixed_Point_Type'Fore;
      Aft   : Natural := Fixed_Point_Type'Aft;
   end record;

   overriding
   procedure Parse (
      Self : in out Fixed_Point_Argument_Type; 
      Edit : String);

   overriding
   function Get_Length (
      Self : in out Fixed_Point_Argument_Type) 
      return Natural;

   overriding
   procedure Put (
      Self : in out Fixed_Point_Argument_Type;
      Edit : String;
      To   : in out String);

end Fmt.Generic_Decimal_Fixed_Point_Argument;
