generic
type Mod_Int_Type is mod <>;
package Fmt.Generic_Mod_Int_Argument is


   function To_Argument (X : Mod_Int_Type) return Argument_Type'Class
      with Inline;

   function "&" (Args : Arguments; X : Mod_Int_Type) return Arguments
      with Inline;

private

   type Digit_Style is (DS_Lowercase, DS_Uppercase);

   subtype Number_Base is Positive range 2 .. 36;

   type Mod_Int_Argument_Type is new Argument_Type with record
      Value : Mod_Int_Type;
      Width : Natural := 0;
      Align : Text_Align := 'R'; 
      Fill  : Character := ' '; 
      Base  : Number_Base := 10;   
      Style : Digit_Style := DS_Lowercase; 
   end record;

   overriding
   procedure Parse (Self : in out Mod_Int_Argument_Type; Edit : String);

   overriding
   function Get_Length (Self : in out Mod_Int_Argument_Type) return Natural;

   overriding
   procedure Put (
      Self : in out Mod_Int_Argument_Type;
      Edit : String;
      To   : in out String);


end Fmt.Generic_Mod_Int_Argument;
