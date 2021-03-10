generic
type Float_Type is digits <>;
package Fmt.Generic_Float_Argument is

   -- float to string
   -- https://www.cs.tufts.edu/~nr/cs257/archive/florian-loitsch/printf.pdf
   -- https://github.com/jk-jeon/dragonbox/blob/master/other_files/Dragonbox.pdf


   -- Edit format
   -- "w=" width
   -- "a=" width after decimal point 
   -- "e=" width of exponent
   -- "f=" width before decimal point

   function To_Argument (X : Float_Type) return Argument_Type'Class
      with Inline;

   function "&" (Args : Arguments; X : Float_Type) return Arguments
      with Inline;

private


   type Float_Argument_Type is new Argument_Type with record
      Value : Float_Type;
      Width : Natural;
      Fore  : Natural := 2;
      Aft   : Natural := Float_Type'Digits - 1;
      Exp   : Natural := 3;
   end record;

   overriding
   procedure Parse (Self : in out Float_Argument_Type; Edit : String);

   overriding
   function Get_Length (Self : in out Float_Argument_Type) return Natural;

   overriding
   procedure Put (
      Self : in out Float_Argument_Type; 
      Edit : String;
      To   : in out String);

end Fmt.Generic_Float_Argument;
