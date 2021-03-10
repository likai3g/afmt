# Ada Format Library


## Introduce


`afmt` is an `Ada` library that provides `function Format (Template : String; Values : Arguments) return String`

Code use `afmt` should look like this:

```Ada

Ada.Text_IO.Put_Line(Format("Multi arguments demo \n Value {1} : \n bin output = {1:b=2} \n hex output = {1:b=16} \n {2}", FAB & 7 & "afmt")); 

Ada.Text_IO.Put_Line(Format("Single argument demo \n Now is {:%Y-%m-%d %H:%M:%S}", Ada.Calendar.Clock));

```

## About the `Format` function

The `Format` function control output via expression in the template look likes `{[INDEX][:EDIT]}` .

Each expression enclosed with `{}`

`INDEX` part is optional, if not present, `Format` internal will generate 
an auto-index .

`:EDIT` part is also optional, if not present, `Format` will use default edit according to the argument type.

NOTE : `EDIT` is parsed by the argument.

## About the `Arguments` and `FAB`

```Ada

type Argument_Ptr is access all Argument_Type'Class;

type Arguments is array(Positive range <>) of Argument_Ptr;

FAB : constant Arguments := [];

```

## About the `Argument_Type`

The `Argument_Type` interface hold type-related `value` and `edit`. 
And pass to `Format` via `Values : Arguments` .
User can extends `Argument_Type` interface to provide new type edit  implementation.


```Ada

type Argument_Type is interface;

-- Argument_Type should implements this method to setup output format
procedure Parse (
  Self : in out Argument_Type;
  Edit : String) is null;

-- Argument_Type should implements this method to tell Format how many bytes need by output.
function Get_Length (
   Self : in out Argument_Type)
   return Natural is abstract;

-- Argument_Type should implements this method to output edited text.
-- The parameter To'Length must equals Get_Length
procedure Put (
   Self : in out Argument_Type;
   Edit : String;
   To   : in out String) is abstract;

```


Implementation example.

```Ada

type Integer_Edit is record
   Base : Positive range 2 .. 36;
end record;

type Integer_Argument is new Argument_Type with record
   Value : Integer; -- hold Value
   Edit  : Integer_Edit; -- hold parsed Edit
end record;


```

## TODO


- Improve ordinary fixed point format performance. 
- Rewrite float point format implementation.
- Implements string edit.










