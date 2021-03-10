with Interfaces; use Interfaces;
with Ada.Unchecked_Conversion;
package body Fmt.Generic_Signed_Int_Argument is

   function To_Argument (X : Signed_Int_Type) return Argument_Type'Class
   is
   begin
      return Signed_Int_Argument_Type'(Value => X, others => <>);
   end To_Argument;

   function "&" (Args : Arguments; X : Signed_Int_Type) return Arguments
   is
   begin
      return Args & To_Argument(X);
   end "&";

   overriding
   procedure Parse (Self : in out Signed_Int_Argument_Type; Edit : String)
   is
      procedure On_KV (K, V : String)
      is
         B : Natural;
         Key : Character;
      begin
         if K'Length /= 1 then
            return;
         end if;
         Key := K(K'First);
         case Key is
            when 'w' =>
               if Is_Decimal_Number(V) then
                  Self.Width := Natural'Value(V);
               end if;
            when 'a' =>
               if V'Length = 1 and then V(V'First) in Text_Align then
                  Self.Align := V(V'First);
               end if;
            when 'f' =>
               if V'Length > 0 then
                  Self.Fill := V(V'First);
               end if;
            when 'b' | 'B' =>
               if Is_Decimal_Number(V) then
                  B := Natural'Value(V);
                  if B in Number_Base then
                     Self.Base := B;
                     Self.Style := (
                        case Key is
                           when 'b'    => DS_Lowercase,
                           when others => DS_Uppercase);
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
      Self : in out Signed_Int_Argument_Type)
      return Natural
   is
      Y : Signed_Int_Type;
      B : Signed_Int_Type;
      L : Natural := 1;
   begin
      if Self.Width /= 0 then
         return Self.Width;
      end if;
      Y := abs Self.Value;
      B := Signed_Int_Type(Self.Base);
      while Y > B - 1 loop
         Y := Y / B;
         L := L + 1;
      end loop;
      if Self.Value < 0 then
         L := L + 1;
      end if;
      return L;
   end Get_length;

   overriding
   procedure Put (
      Self : in out Signed_Int_Argument_Type;
      Edit : String;
      To   : in out String)
   is
      MS : constant array(Digit_Style) of String(1 .. Number_Base'Last) := (
         "0123456789abcdefghijklmnopqrstuvwxyz",
         "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ");
      M : String renames MS(Self.Style);
      B : constant Unsigned_64 := Unsigned_64(Self.Base);
      Y : Unsigned_64 := Safe_Abs(Long_Long_Integer(Self.Value));
      L : Natural := To'Last;
   begin
      loop
         To(L) := M(Natural(Y mod B + 1));
         Y := Y / B;
         L := L - 1;
         exit when L < To'First;
         exit when Y = 0;
      end loop;
      if Self.Value < 0 then
         To(L) := '-';
         L := L - 1;
      end if;
      for Fill of To(To'First .. L) loop
         Fill := Self.Fill;
      end loop;
      case Self.Align is
         when 'L' =>
            declare
               V : String renames To(L + 1 .. To'Last);
               F : String renames To(To'First .. L);
            begin
               if F'Length > 0 then
                  -- swap order
                  To := V & F;
               end if;
            end;
         when 'M' =>
            declare
               V : String renames To(L + 1 .. To'Last);
               F : String renames To(To'First .. L);
               C : Natural;
            begin
               if F'Length > 1 then
                  C := F'First + F'Length / 2 - 1;
                  -- split fill part
                  To := F(F'First .. C) & V & F(C + 1 .. F'Last);
               end if;
            end;
         when others =>
            null;
      end case;
   end Put;

end Fmt.Generic_Signed_Int_Argument;

