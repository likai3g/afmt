with Ada.Containers;
with Fmt.Generic_Signed_Int_Argument;
package Fmt.Count_Argument is
   new Fmt.Generic_Signed_Int_Argument(Ada.Containers.Count_Type);
