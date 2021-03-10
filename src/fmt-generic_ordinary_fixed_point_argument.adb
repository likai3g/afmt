pragma Ada_2020;
with Interfaces; use Interfaces;
with Ada.Numerics;
with Ada.Numerics.Generic_Elementary_Functions;
package body Fmt.Generic_Ordinary_Fixed_Point_Argument is


   package Math is
      new Ada.Numerics.Generic_Elementary_Functions(Long_Float);

   Exp       : constant Long_Long_Float := 10.0 ** Fixed_Point_Type'Aft;
   Scale     : constant Long_Long_Float := Fixed_Point_Type'Small * Exp;
   Int_Scale : constant Long_Long_Integer := Long_Long_Integer(Scale);
   To_Char   : constant array(Unsigned_64 range 0 .. 9) of Character := "0123456789";

   type Display_Goal is record
      N : Unsigned_64; -- a number maybe very big
      M : Unsigned_64; -- a scale number, maybe very big
      P : Unsigned_64; -- a patch value, at most two digits
   end record;

   type Decimal is record
      K : Unsigned_64; -- coefficient
      R : Unsigned_64; -- remainder, one digit
   end record;

--   Dec_Cache : array (Long_Long_Integer range 0 .. 1000) of Decimal :=
--      [for I in Long_Long_Integer range 0 .. 1000 => (I / 10, I mod 10)];

   function To_Long_Long_Integer (X : Fixed_Point_Type) return Long_Long_Integer
      with Pre => Fixed_Point_Type'Base'Size in 8 | 16 | 32 | 64;

   function To_Long_Long_Integer (X : Fixed_Point_Type) return Long_Long_Integer
   is
      BX : Fixed_Point_Type'Base := X;
   begin
      case Fixed_Point_Type'Base'Size is
         when 8 =>
            declare
               i : Integer_8 with Address => BX'Address;
            begin
               return Long_Long_Integer(i);
            end;
         when 16 =>
            declare
               i : Integer_16 with Address => BX'Address;
            begin
               return Long_Long_Integer(i);
            end;
         when 32 =>
            declare
               i : Integer_32 with Address => BX'Address;
            begin
               return Long_Long_Integer(i);
            end;
         when 64 =>
            declare
               i : Integer_64 with Address => BX'Address;
            begin
               return Long_Long_Integer(i);
            end;
         when others =>
            raise Storage_Error;
      end case;
   end To_Long_Long_Integer;

   function Compute_Multiply_Result_Length (
      N, M : Long_Long_Integer) 
      return Natural
   is
      L : Natural := 0;
      X : Unsigned_64 := Safe_Abs(N);
   begin
      loop
         L := L + 1;
         X := X / 10;
         exit when X = 0;
      end loop;
      X := Safe_Abs(M);
      loop
         L := L + 1;
         X := X / 10;
         exit when X = 0;
      end loop;
      if N < 0 then
         L := L + 1;
      end if;
      return L;
   end Compute_Multiply_Result_Length;

   function To_Argument (X : Fixed_Point_Type) return Argument_Type'Class
   is
   begin
      return Fixed_Point_Argument_Type'(Value => X, others => <>);
   end To_Argument;

   function "&" (Args : Arguments; X : Fixed_Point_Type) return Arguments
   is
   begin
      return Args & To_Argument(X);
   end "&";

   overriding
   procedure Parse (Self : in out Fixed_Point_Argument_Type; Edit : String)
   is
      procedure Conf (K, V : String)
      is
      begin
         if K'Length /= 1 or else V'Length = 0 then
            return;
         end if;
         case K(K'First) is
            when 'a' =>
               if Is_Decimal_Number(V) then
                  Self.Aft := Natural'Value(V);
               end if;
            when 'w' =>
               if Is_Decimal_Number(V) then
                  Self.Width := Natural'Value(V);
               end if;
            when others =>
               null;
         end case;
      end Conf;
   begin
      Parse_KV_Edit(Edit, Conf'Access);
   end Parse;

   overriding
   function Get_Length (Self : in out Fixed_Point_Argument_Type) return Natural
   is
   begin
      if Self.Width /= 0 then
         return Self.Width;
      else
         return Compute_Multiply_Result_Length(
            N => To_Long_Long_Integer(Self.Value), 
            M => Int_Scale);
      end if;
   end Get_Length;

   function Split (X : Unsigned_64) return Decimal
   is
      pragma Inline(Split);
   begin
      return (K => X / 10, R => X mod 10);
   end Split;


   overriding
   procedure Put (
      Self : in out Fixed_Point_Argument_Type;
      Edit : String;
      To   : in out String)
   is
      Dot_Pos : constant Integer := To'Last - Fixed_Point_Type'Aft;
      H : constant Natural := To'First;
      L : Natural := To'Last;
      V : constant Long_Long_Integer := To_Long_Long_Integer(Self.Value);
      G : Display_Goal := (Safe_Abs(V), Safe_Abs(Int_Scale), 0);
      N, M, R, Y : Decimal;

      procedure Display (Digit : Unsigned_64)
      is
         pragma Inline(Display);
      begin
         if L = Dot_Pos then
            To(L) := '.';
            L := L - 1;
            if L < H then
               return;
            end if;
         end if;
         To(L) := To_Char(Digit);
         -- To(L) := Character'Val(Digit + Character'Pos('0'));
         L := L - 1;
      end Display;
   begin
      loop
         N := Split(G.N);
         M := Split(G.M);
         R := Split(N.R * M.R + G.P);
         Y := Split(N.K * M.R + M.K * N.R + R.K);
         Display(R.R);
         exit when L < H; -- To'First;
         Display(Y.R);
         exit when L < H; -- To'First;
         -- adjust next goal
         G := (N.K, M.K, Y.K);                                                  
         exit when G = (0, 0, 0);
      end loop;
     while L + 1 < To'Last loop
        exit when To(L + 1) /= '0';
        To(L + 1) := ' ';
        L := L + 1;
     end loop;
      if V < 0 then
         To(L) := '-';
         L := L - 1;
      end if;
      if L >= To'First then
         To(To'First .. L) := (others => Self.Fill);
      end if;
   end Put;

end Fmt.Generic_Ordinary_Fixed_Point_Argument;
