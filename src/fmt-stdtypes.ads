with Ada.Calendar;
with Fmt.Time_Argument;
with Fmt.String_Argument;
with Fmt.Integer_Argument;
with Fmt.Duration_Argument;
package Fmt.Stdtypes is


   -- integer support

   -- edit format (control_char=control_value;...)
   -- "w=" width
   -- "a=" align
   -- "f=" fillchar
   -- "b=" base (use lowercase extended digit)
   -- "B=" base (use uppercase extended digit)
   function "&" (Args : Arguments; X : Integer) return Arguments
      renames Integer_Argument."&";

   function To_Argument (X : Integer) return Argument_Type'Class
      renames Integer_Argument.To_Argument;

   function Format is new Generic_Format(Integer);

   -- time support
   
   -- edit format
   -- "%y" : year  (yy)
   -- "%Y" : year  (yyyy)
   -- "%m" : month (mm)
   -- "%d" : day   (dd)
   -- "%H" : hour  (HH)
   -- "%M" : min   (MM)
   -- "%S" : sec   (SS)
   function "&" (Args : Arguments; X : Ada.Calendar.Time) return Arguments
      renames Time_Argument."&";

   function To_Argument (X : Ada.Calendar.Time) return Argument_Type'Class
      renames Time_Argument.To_Argument;

   function Format is new Generic_Format(Ada.Calendar.Time);

   function "&" (Args : Arguments; X : Duration) return Arguments
      renames Duration_Argument."&";

   function To_Argument (X : Duration) return Argument_Type'Class
      renames Duration_Argument.To_Argument;

   function Format is new Generic_Format(Duration);

   -- utf8 string support
   
   -- edit format :
   -- "w=" width
   -- "a=" align
   -- "f=" fillchar
   -- "A=" unmask align
   -- "W=" unmask width
   -- "F=" maskchar fill
   -- "s=" style ("O|L|U|F") 
   -- for example
   -- Format("hello, {:w=10,f= ,W=3,A=l,F=*}", "kylix") 
   -- output : "hello,      **lix"
   function "&" (Args : Arguments; X : String) return Arguments
      renames String_Argument."&";

   function To_Argument (X : String) return Argument_Type'Class
      renames String_Argument.To_Argument;

   function Format is new Generic_Format(String);

end Fmt.Stdtypes;
