pragma Ada_2020;
with Interfaces;
---- Ada String Format Library
---- @usages:
--    -- specified argumnent index
--    with Fmt, Fmt.Stdtypes;
--    use Fmt, Fmt.Stdtypes;
--    ...
--    Ada.Text_IO.Put_Line(Format("{1:%H-%M-%S} {2}", FAB & Ada.Calendar.Clock & Message));
--    Ada.Text_IO.Put_Line(Format("bin view of {1:b=10} is {1:b=2}", 123));
--    -- auto argument index
--    Ada.Text_IO.Put_Line(Format("{:%H-%M-%S} {} ", FAB & Ada.Calendar.Clock & Message));
--    -- escape character
--    Ada.Text_IO.Put_Line(Format("hello, \n, world"));
package Fmt is

   type Argument_Type is interface;
   -- Argument_Type bind template variant with specified EDIT
   -- e.g
   -- Put_Line(Format("{1:w=4,f=0}", To_Argument(123)));
   -- INDEX :           ^
   -- EDIT :              ^^^^^^^

   procedure Parse (
      Self : in out Argument_Type;
      Edit : String) is null;
   -- Parse "{" [Index] ":" Edit "}" to internal display format settings.
   -- @param Edit : type related format. e.g. "w=3,b=16"

   function Get_Length (
      Self : in out Argument_Type)
      return Natural is abstract;
   -- Compute output string length in bytes.
   -- @remarks : This function called after `Parse`

   procedure Put (
      Self : in out Argument_Type;
      Edit : String;
      To   : in out String) is abstract;
   -- Generate output string 
   -- @param To : target string with length computed by `Get_Length`

   procedure Finalize (Self : in out Argument_Type) is null;
   -- this routing call before Format return edited result


   type Argument_Ptr is access all Argument_Type'Class;

   type Arguments is array(Positive range <>) of Argument_Ptr;
   -- Arguments pass to `Format` argument `Values`

   function "&" (Values : Arguments; New_Item : Argument_Type'Class) return Arguments
      with Inline;

   FAB : constant Arguments := [];
   -- empty Arguments

   function Format (
      Template : String;
      Values   : Arguments := FAB)
      return String;
   -- Given Template and Values, output final text
   -- @param Template : compound by expr and non expr parts 
   --    the expr part wrapped with "{}", contains an optional Value_Index and some optional Edit info
   --       Value_Index is positive, should compound by dec digits 
   --       if no Value_Index specified, Format will auto increase Value_Index according to Values
   --       Edit info interpret by the Argument_Type.Parse 
   --    the non expr part can use character '\' to output specific character 
   -- @param Values : values to replace the expr in the Template
   -- @example:
   --     Format("x + y = {3:b=16,w=8,f=0}, x = {1}, y = {2}\n", FAB & x & y & (x + y))

   function Format (
      Template : String;
      Value    : Argument_Type'Class)
      return String;
   -- Format one argument with given template

   generic
   type Value_Type (<>) is limited private;
   with function To_Argument (V : Value_Type) return Argument_Type'Class is <>;
   function Generic_Format (
      Template : String;
      Value    : Value_Type)
      return String;
   -- Simplified one argument format

   procedure Parse_KV_Edit (
      Edit : String;
      Conf : not null access procedure(K : String; V : String));
   -- Routing for implements `Argument_Type.Parse`.
   -- Each `key`, `value` pair seperate by delimiter ','.
   -- The `key` and `value` seperate by '='.


   subtype Decimal_Digit is Character range '0' .. '9';
   
   subtype Hex_Digit is Character 
   with Static_Predicate => Hex_Digit in '0' .. '9' | 'a' .. 'f' | 'A' .. 'F';

   function Is_Decimal_Number (S : String) return Boolean
      with Inline;

   subtype Text_Align is Character
   with Static_Predicate => Text_Align in 'L' | 'M' | 'R';

   type Placeholder_Argument_Type is abstract new Argument_Type with record
      Length : Natural := 0;
      Default_Edit : access constant String := null;
   end record;
   -- Placeholder_Argument_Type bind template variant with specified format
   -- The Argument value may contains multiparts. 
   -- Each part expressed as placeholder (with prefix %) in the EDIT
   -- e.g  
   -- Format("{:%Y-%m-%d %H:%M:%S}", To_Argument(Ada.Calendar.Clock));
   -- EDIT :    ^^^^^^^^^^^^^^^^^ 
   --           ^^                -> placeholder Y
   --              ^^             -> placeholder m

   function Is_Valid_Placeholder (
      Self : Placeholder_Argument_Type;
      Name : Character)
      return Boolean is abstract;
   -- Given a character, detect whether it is a placeholder

   function Get_Placeholder_Width (
      Self : in out Placeholder_Argument_Type;
      Name : Character)
      return Natural is abstract;
   -- Given a placeholder, tell the edit width

   procedure Put_Placeholder (
      Self : in out Placeholder_Argument_Type;
      Name : Character;
      To   : in out String) is abstract;
   -- Replace placeholder with context related text

   overriding
   procedure Parse (
      Self : in out Placeholder_Argument_Type;
      Edit : String);
   -- Note : if Edit is empty then Default_Edit will apply

   overriding
   function Get_Length (
      Self : in out Placeholder_Argument_Type) 
      return Natural;

   overriding
   procedure Put (
      Self : in out Placeholder_Argument_Type;
      Edit : String;
      To   : in out String);
   ---- Note : if Edit is empty then Default_Edit will apply



private

   function Safe_Abs (X : Long_Long_Integer) return Interfaces.Unsigned_64
      with Inline;



end Fmt;
