with Ada.Calendar.Time_Zones;
with Ada.Calendar.Formatting;
with Fmt.Integer_Argument;
package body Fmt.Time_Argument is

   Default_Time_Edit : aliased constant String := "%Y-%m-%d %H:%M:%S";

   overriding
   function Get_Placeholder_Width (
      Self : in out Time_Argument_Type;
      Name : Character)
      return Natural
   is
   begin
      return (
         case Name is
            when 'Y' => 4,
            when 'y' | 'm' | 'd' | 'H' | 'M' | 'S' => 2,
            when others => 0);
   end Get_Placeholder_Width;

   overriding
   function Is_Valid_Placeholder (
      Self : Time_Argument_Type;
      Name : Character)
      return Boolean
   is
   begin
      return Name in 'Y' | 'y' | 'm' | 'd' | 'H' | 'M' | 'S';
   end Is_Valid_Placeholder;

   overriding
   procedure Put_Placeholder (
      Self : in out Time_Argument_Type;
      Name : Character;
      To   : in out String)
   is
      use Ada.Calendar.Formatting;
      use Ada.Calendar.Time_Zones;
      use Integer_Argument;
      TZ : constant Time_Offset := Local_Time_Offset(Self.Value);
   begin
      case Name is
         when 'Y' => To := Format("{:w=4,f=0}", To_Argument(Year(Self.Value, TZ)));
         when 'm' => To := Format("{:w=2,f=0}", To_Argument(Month(Self.Value, TZ)));
         when 'd' => To := Format("{:w=2,f=0}", To_Argument(Day(Self.Value, TZ)));
         when 'H' => To := Format("{:w=2,f=0}", To_Argument(Hour(Self.Value, TZ)));
         when 'M' => To := Format("{:w=2,f=0}", To_Argument(Minute(Self.Value, TZ)));
         when 'S' => To := Format("{:w=2,f=0}", To_Argument(Second(Self.Value)));
         when others => null;
      end case;
   end Put_Placeholder;


   function To_Argument (X : Ada.Calendar.Time) return Argument_Type'Class
   is
   begin
      return Time_Argument_Type'(
         Value => X, 
         Default_Edit => Default_Time_Edit'Access,
         others => <>);
   end To_Argument;

   function "&" (Args : Arguments; X : Ada.Calendar.Time) return Arguments
   is
   begin
      return Args & To_Argument(X);
   end "&";

end Fmt.Time_Argument;
