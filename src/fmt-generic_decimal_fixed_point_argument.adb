with Interfaces;
package body Fmt.Generic_Decimal_Fixed_Point_Argument is

   Scale : constant Long_Long_Integer := 10 ** Fixed_Point_Type'Scale;

   function To_Long_Long_Integer (X : Fixed_Point_Type) return Long_Long_Integer
   is
      use Interfaces;
   begin
      case Fixed_Point_Type'Size is
         when 0 .. 8 =>
            declare
               i : Integer_8 with Address => X'Address;
            begin
               return Long_Long_Integer(i);
            end;
         when 9 .. 16 =>
            declare
               i : Integer_16 with Address => X'Address;
            begin
               return Long_Long_Integer(i);
            end;
         when 17 .. 32 =>
            declare
               i : Integer_32 with Address => X'Address;
            begin
               return Long_Long_Integer(i);
            end;
         when others =>
            declare
               i : Integer_64 with Address => X'Address;
            begin
               return Long_Long_Integer(i);
            end;
      end case;
   end To_Long_Long_Integer;

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
         declare
            X : constant Long_Long_Integer := To_Long_Long_Integer(Self.Value);
            Y : Long_Long_Integer := abs X;
            L : Natural := 1 + Self.Aft; 
         begin
            for I in 1 .. Self.Aft loop
               exit when Y = 0;
               Y := Y / 10;
            end loop;
            for I in 1 .. Self.Fore loop
               Y := Y / 10;
               L := L + 1;
               exit when Y = 0;
            end loop;
            if X < 0 then
               L := L + 1;
            end if;
            return L;
         end;
      end if;
   end Get_Length;

   overriding
   procedure Put (
      Self : in out Fixed_Point_Argument_Type;
      Edit : String;
      To   : in out String)
   is
      M : constant array(Long_Long_Integer range 0..9) of Character := "0123456789";
      T : constant Natural := To'Last + 1;
      H : constant Natural := To'First;
      X : constant Long_Long_Integer := To_Long_Long_Integer(Self.Value);
      Y : Long_Long_Integer := abs X;
      L : Natural := To'Last;
      A : Natural;
   begin
      -- output aft 
      -- if user defined aft > real aft, padding with 0
      if Self.Aft > Fixed_Point_Type'Aft then
         -- padding exceed aft with '0'
         for I in Fixed_Point_Type'Aft + 1 .. Self.AFt loop
            To(L) := '0';
            L := L - 1;
            if L < H then
               return;
            end if;
         end loop;
         A := Fixed_Point_Type'Aft;
      else
         -- skip invisiable digits
         for I in Self.Aft + 1 .. Fixed_Point_Type'Aft loop
            Y := Y / 10;
         end loop;
         A := Self.Aft;
      end if;
      for I in 1 .. A loop
         To(L) := M(Y mod 10);
         Y := Y / 10;
         L := L - 1;
         if L < H then
            return;
         end if;
         exit when Y = 0;
      end loop;
      -- output decimal point
      To(L) := '.';
      L := L - 1;
      if L < H then
         return;
      end if;
      -- output fore
      for I in Natural range 1 .. Self.Fore loop
         To(L) := M(Y mod 10);
         Y := Y / 10;
         L := L - 1;
         if L < H then
            return;
         end if;
         exit when Y = 0;
      end loop;
      -- output sign
      if L < H then
         return;
      end if;
      if X < 0 then
         To(L) := '-';
         L := L - 1;
      end if;
      To(To'First .. L) := (others => Self.Fill);
   end Put;

end Fmt.Generic_Decimal_Fixed_Point_Argument;
