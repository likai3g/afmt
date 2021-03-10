pragma Ada_2020;
with Ada.Text_IO;
with Ada.Unchecked_Conversion;
with System;
package body Fmt is

   function To_Ptr is
      new Ada.Unchecked_Conversion(System.Address, Argument_Ptr);

   function "&" (Values : Arguments; New_Item : Argument_Type'Class) return Arguments
   is
   begin
      return Values & To_Ptr(New_Item'Address);
   end "&";

   type Piece_Info is record
      Begin_At : Positive; -- first pos include in piece
      End_At   : Natural;  -- first pos not include in piece
      Length   : Natural;  -- final length
      Arg_Id   : Natural;  -- >0 when the piece is an expr, 
      Num_Esc  : Natural;  -- >0 when the piece contains escape char
   end record;

   type Piece_Infos is array(Positive range <>) of Piece_Info;

   function Total_Length (PS : Piece_Infos) return Natural
   is
      L : Natural := 0;
   begin
      -- return [for P of PS => P.Length]'Reduce("+", 0);
      for P of PS loop
         L := L + P.Length;
      end loop;
      return L;
   end Total_Length;

   function Get_Expr_Count (
      Template : String)
      return Natural
   is
      R : Natural := 0;
      I : Positive := Template'First;
   begin
      while I < Template'Last loop
         case Template(I) is
            when '\' =>
               I := I + 2;
            when '{' =>
               I := I + 1;
               while I < Template'Last loop
                  exit when Template(I) = '}';
                  I := I + 1;
               end loop;
               I := I + 1;
               R := R + 1;
            when others =>
               I := I + 1;
         end case;
      end loop;
      return R;
   end Get_Expr_Count;

   function Compute_Piece_Infos (
      Template : String;
      Values   : Arguments)
      return Piece_Infos 
   is
      Info : Piece_Infos(1 .. Get_Expr_Count(Template) * 2 + 1);
      I : Natural := Template'First;
      NB, NE : Natural;
      SB, SE : Natural;
      K : Positive := Info'First;
      Auto_Id : Positive := Values'First;
   begin
      Info(K) := (I, I, 0, 0, 0);
      loop
         case Template(I) is
            when '{' =>
               K := K + 1;
               Info(K) := (I, I, 0, 0, 0);
               -- scan optional arg_id
               NB := I + 1;
               NE := NB;
               while NE < Template'Last loop
                  exit when not (Template(NE) in '0' .. '9');
                  Info(K).Arg_Id := Info(K).Arg_Id * 10 + Character'Pos(Template(NE)) - Character'Pos('0');
                  NE := NE + 1;
               end loop;
               if NE = NB then
                  Info(K).Arg_Id := Auto_Id;
                  Auto_Id := Auto_Id + 1;
               end if;
               -- scan Edit info
               SB := NE;
               SE := SB;
               while SE < Template'Last loop
                  exit when Template(SE) = '}';
                  SE := SE + 1;
               end loop;
               Info(K).End_At := SE + 1;
               if Info(K).Arg_Id in Values'Range then
                  declare
                     Arg : constant Argument_Ptr := Values(Info(K).Arg_Id);
                  begin
                     if Template(SB) = ':' then
                        Arg.Parse(Template(SB + 1 .. SE - 1));
                     else
                        -- always call Parse
                        -- Arugment may set default edit here
                        Arg.Parse("");
                     end if;
                     Info(K).Length := Arg.Get_Length; 
                  end;
               else
                  -- index invalid, treat as empty piece
                  Info(K).Arg_Id := 0;
               end if;
               -- scan next piece
               K := K + 1;
               I := SE + 1;
               Info(K) := (I, I, 0, 0, 0);
               exit when I > Template'Last;
            when '\' =>
               Info(K).Num_Esc := Info(K).Num_Esc + 1;
               I := I + 1;
               Info(K).End_At := I;
               exit when I > Template'Last;
               I := I + 1;
               Info(K).Length := Info(K).Length + 1;
               Info(K).End_At := I;
               exit when I > Template'Last;
            when others =>
               I := I + 1;
               Info(K).Length := Info(K).Length + 1;
               Info(K).End_At := I;
               exit when I > Template'Last;
         end case;
      end loop;
      return Info;
   end Compute_Piece_Infos;

   function Get_Edit_Begin_Pos (Source : String) return Natural
   is
   begin
      for I in Source'Range loop
         if Source(I) = ':' then
            return I + 1;
         end if;
      end loop;
      return Source'Last + 1;
   end Get_Edit_Begin_Pos;

   function Format (
      Template : String;
      Values   : Arguments := FAB)
      return String
   is
      PS : Piece_Infos := Compute_Piece_Infos(Template, Values);
      R : String(1 .. Total_Length(PS));
      I : Positive := R'First;
   begin
      for P of PS loop
         if P.Length > 0 then
            declare
               RP : String renames R(I .. I + P.Length - 1);
               TS : String renames Template(P.Begin_At .. P.End_At - 1);
               PB, PE : Natural;
               RF, RL : Natural;
               Ch : Character;
            begin
               if P.Arg_Id /= 0 then
                  declare
                     Arg : constant Argument_Ptr := Values(P.Arg_Id);
                  begin
                     Arg.Put(TS(Get_Edit_Begin_Pos(TS) .. TS'Last - 1), RP);
                  end;
               else
                  if P.Num_Esc = 0 then
                     RP := TS;
                  else
                     PB := P.Begin_At;
                     RF := RP'First;
                     while P.Num_Esc > 0 loop
                        PE := PB;
                        -- find next esc pos
                        while PE < P.End_At loop
                           exit when Template(PE) = '\';
                           PE := PE + 1;
                        end loop;
                        RL := PE - PB;
                        if RL > 0 then
                           -- copy non esc part
                           RP(RF .. RF + RL - 1) := Template(PB .. PE - 1);
                        end if;
                        PB := PE + 1;
                        RF := RF + RL;
                        if PB < P.End_At then
                           -- copy esc char
                           Ch := Template(PB);
                           case Ch is
                              when 'n' => 
                                 RP(RF) := ASCII.LF;
                              when 't' =>
                                 RP(RF) := ASCII.HT;
                              when 'r' =>
                                 RP(RF) := ASCII.CR;
                              when others =>
                                 RP(RF) := Ch;
                           end case;
                           RF := RF + 1;
                           PB := PB + 1;
                        end if;
                        P.Num_Esc := P.Num_Esc - 1;
                     end loop;
                     -- final part
                     if RF <= RP'Last then
                        RP(RF .. RP'Last) := Template(PB .. P.End_At - 1);
                     end if;
                  end if;
               end if;
            end;
            I := I + P.Length;
         end if;
      end loop;
      -- TODO
      -- finalize values here?
      return R;
   end Format;

   function Format (
      Template : String;
      Value    : Argument_Type'Class)
      return String
   is
      Values : constant Arguments := [To_Ptr(Value'Address)];
   begin
      return Format(Template, Values);
   end Format;

   function Generic_Format (
      Template : String;
      Value    : Value_Type)
      return String
   is
   begin
      return Format(Template, To_Argument(Value));
   end Generic_Format;

   procedure Parse_KV_Edit (
      Edit : String;
      Conf : not null access procedure(K : String; V : String))
   is
      ET : constant Positive := Edit'Last + 1;
      KB, KE : Positive;
      VB, VE : Positive;
   begin
      KB := Edit'First;
      while KB < ET loop
         KE := KB;
         while KE < ET loop
            exit when Edit(KE) = '=';
            KE := KE + 1;
         end loop;
         VB := KE + 1;
         VE := VB;
         while VE < ET loop
            exit when Edit(VE) = ',';
            VE := VE + 1;
         end loop;
         if KE > KB then
            Conf(Edit(KB .. KE - 1), Edit(VB .. VE - 1));
         end if;
         KB := VE + 1;
      end loop;
   end Parse_KV_Edit;

   overriding
   procedure Parse (
      Self : in out Placeholder_Argument_Type;
      Edit : String)
   is
      subtype Virtual is Placeholder_Argument_Type'Class;
      T : constant Natural := Edit'Last;
      I : Natural := Edit'First;
      W : Natural := 0;
   begin
      if Edit'Length > 0 then
         while I < T loop
            if Edit(I) = '%' and then Virtual(Self).Is_Valid_Placeholder(Edit(I + 1)) then
               I := I + 1;
               W := W + Virtual(Self).Get_Placeholder_Width(Edit(I));
            else
               W := W + 1;
            end if;
            I := I + 1;
         end loop;
         Self.Length := W;
      elsif Self.Default_Edit /= null and then Self.Default_Edit'Length > 0 then
         Self.Parse(Self.Default_Edit.all); 
      end if;
   end Parse;

   overriding
   function Get_Length (
      Self : in out Placeholder_Argument_Type) 
      return Natural
   is
   begin
      return Self.Length;
   end Get_Length;

   overriding
   procedure Put (
      Self : in out Placeholder_Argument_Type;
      Edit : String;
      To   : in out String)
   is
      subtype Virtual is Placeholder_Argument_Type'Class;
      T : constant Natural := Edit'Last;
      EB, EE : Natural; -- edit piece range
      TB, TE : Natural; -- to piece range
      Name : Character;
   begin
      if Edit'Length > 0 then
         EB := Edit'First;
         EE := EB;
         TB := To'First;
         TE := TB;
         while EE < T loop
            if Edit(EE) = '%' and then Virtual(Self).Is_Valid_Placeholder(Edit(EE + 1)) then
               -- output non placeholder
               To(TB .. TE - 1) := Edit(EB .. EE - 1);
               -- output placeholder
               Name := Edit(EE + 1);
               TB := TE;
               TE := TB + Virtual(Self).Get_Placeholder_Width(Name);
               Virtual(Self).Put_Placeholder(Name, To(TB .. TE - 1));
               -- next piece
               EB := EE + 2;
               EE := EB;
               TB := TE;
               TE := TB;
            else
               EE := EE + 1;
               TE := TE + 1;
            end if;
         end loop;
         if EB <= Edit'Last then
            To(TB .. To'Last) := Edit(EB .. Edit'Last);
         end if;
      elsif Self.Default_Edit /= null and then Self.Default_Edit'Length > 0 then
         Self.Put(Virtual(Self).Default_Edit.all, To);
      end if;
   end Put;

   function Is_Decimal_Number (S : String) return Boolean
   is
   begin
      return S'Length > 0 and then (for all Ch of S => Ch in Decimal_Digit);
   end Is_Decimal_Number;

   function Safe_Abs (X : Long_Long_Integer) return Interfaces.Unsigned_64
   is
      use Interfaces;

      function Cast is
         new Ada.Unchecked_Conversion(Long_Long_Integer, Unsigned_64);

      V : constant Unsigned_64 := Cast(X);
   begin
      return (if X < 0 then not V + 1 else V);
   end Safe_Abs;


end Fmt;
