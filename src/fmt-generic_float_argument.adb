with Ada.Text_IO;
package body Fmt.Generic_Float_Argument is

   package FIO is new Ada.Text_IO.Float_IO(Float_Type);

   -- IEEE754 浮点格式
   -- 浮点由三部分构成(符号位, 指数, 小数部分)
   -- 指数的二进制位数称为k
   -- 小数的二进制位数称为M
   --
   --
   -- 单精度(32位)
   -- bit 31 : 符号位 (Sign)
   -- bit 30 - bit 23 : 指数部分(Exponent), 长度为8, 记为k
   -- bit 22 - bit 0  : 尾数部分(Mantissa), 长度为23, 记为M
   -- 指数部分不含符号位(1..254)表示-126 .. 127), 0和255有特殊含义
   -- 因此对实际的指数值，需要统一加上一个偏置值(bias)进行表示
   -- 单精度中这个偏置值为127 (2 << (k-2) - 1)
   -- 当指数部分非特殊值时, 基数的整数部分隐含为1
   --
   -- 特殊浮点数
   --
   -- NaN   : 指数部分全为1且尾数部分非0
   -- 无穷大: 当指数部分全为1且尾数部分全0
   -- 非格化值: 当指数部分全为0时, 只含整数部分
   --
   -- 双精度浮点数(64位)
   -- k=11,M=52

   overriding
   procedure Parse (Self : in out Float_Argument_Type; Edit : String)
   is
      procedure Conf (K, V : String)
      is
      begin
         if K'Length /= 1 then
            return;
         end if;
         case K(K'First) is
            when 'w' =>
               if (for all ch of V => ch in '0' .. '9') then
                  Self.Width := Natural'Value(V);
               end if;
            when 'a' =>
               if (for all ch of V => ch in '0' .. '9') then
                  Self.Aft := Natural'Value(V);
               end if;
            when 'e' =>
               if (for all ch of V => ch in '0' .. '9') then
                  Self.Exp := Natural'Value(V);
                  if Self.Exp /= 0 then
                     Self.Exp := Self.Exp + 2;
                  end if;
               end if;
            when 'f' =>
               if (for all ch of V => ch in '0' .. '9') then
                  Self.Fore := Natural'Value(V);
               end if;
            when others =>
               null;
         end case;
      end Conf;
   begin
      Parse_KV_Edit(Edit, Conf'Access);
   end Parse;

   overriding
   function Get_Length (Self : in out Float_Argument_Type) return Natural
   is
   begin
      return Self.Fore + Self.Aft + Self.Exp;
   end Get_Length;

   overriding
   procedure Put (
      Self : in out Float_Argument_Type; 
      Edit : String;
      To   : in out String)
   is
   begin
      FIO.Put(To, Self.Value, Ada.Text_IO.Field(Self.Aft), Ada.Text_IO.Field(Self.Exp));
   end Put;

   function To_Argument (X : Float_Type) return Argument_Type'Class
   is
   begin
      return Float_Argument_Type'(Value => X, others => <>);
   end To_Argument;

   function "&" (Args : Arguments; X : Float_Type) return Arguments
   is
   begin
      return Args & To_Argument(X);
   end "&";

end Fmt.Generic_Float_Argument;
