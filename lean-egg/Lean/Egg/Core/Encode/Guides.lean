import Egg.Core.Guides
import Egg.Core.Encode.Basic
import Lean
open Lean

namespace Egg

abbrev Guide.Encoded := Expression

abbrev Guides.Encoded := Array Guide.Encoded

def Guides.encode (guides : Guides) (ctx : EncodingCtx) : MetaM Guides.Encoded :=
  guides.mapM fun guide => Egg.encode guide.expr ctx
