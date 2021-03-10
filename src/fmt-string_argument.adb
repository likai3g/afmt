package body Fmt.String_Argument is

   function UTF8_Length (Ch : Character) return Natural 
   is
   begin
      case Character'Pos(Ch) is 
         when 2#00_000000# .. 2#01_111111# =>
            return 1;
         when 2#110_00000# .. 2#110_11111# =>
            return 2;
         when 2#1110_0000# .. 2#1110_1111# =>
            return 3;
         when 2#11110_000# .. 2#11110_111# =>
            return 4;
         when 2#111110_00# .. 2#111110_00# =>
            return 5;
         when 2#1111110_0# .. 2#1111110_1# =>
            return 6;
         when others =>
            return 0;
      end case;
   end UTF8_Length;
   


   overriding
   procedure Parse (
      Self : in out String_Argument_Type;
      Edit : String)
   is
      procedure On_KV (K, V : String)
      is
      begin
         if K'Length /= 1 then
            return;
         end if;
         case K(K'First) is
            when 'w' =>
               if Is_Decimal_Number(V) then
                  Self.Width := Natural'Value(V);
               end if;
            when 'a' =>
               if V'Length = 1 and then V(V'First) in Text_Align then
                  Self.Align := V(V'First);
               end if;
            when 'f' =>
               -- decode utf8 bound
               if V'Length = 0 then
                  Self.Fill_l := 0;
               else
                  Self.Fill_L := UTF8_Length(V(V'First));
                  if V'Length < Self.Fill_L then
                     -- illgel utf8 character
                     Self.Fill_L := 0;
                  else
                     Self.Fill(1..Self.Fill_L) := V(V'First .. V'First + Self.Fill_L - 1);
                  end if;
               end if;
            when others =>
               null;
         end case;
      end On_KV;
   begin
      Parse_KV_Edit(Edit, On_KV'Access);
   end Parse;

   overriding
   function Get_Length (
      Self : in out String_Argument_Type)
      return Natural
   is
   begin
      return Self.Size;
   end Get_Length;

   overriding
   procedure Put (
      Self : in out String_Argument_Type;
      Edit : String;
      To   : in out String)
   is
   begin
      if To'Length > 0 then
         declare
            Source : String(1 .. Self.Size) with Address => Self.Value;
         begin
            To := Source;
         end;
      end if;
   end Put;

   function To_Argument (X : String) return Argument_Type'Class
   is
   begin
      return String_Argument_Type'(
         Value  => (if X'Length > 0 then X(X'First)'Address else System.Null_Address),
         Size   => X'Length,
         others => <>);
   end To_Argument;

   function "&" (Args : Arguments; X : String) return Arguments
   is
   begin
      return Args & To_Argument(X);
   end "&";

end Fmt.String_Argument;

