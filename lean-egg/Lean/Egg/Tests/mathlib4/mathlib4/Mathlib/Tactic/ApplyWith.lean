import Mathlib.Testing.Egg.SimpOnlyOverride
/-
Copyright (c) 2022 Mario Carneiro. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro
-/
import Mathlib.Init
import Lean.Elab.Eval
import Lean.Elab.Tactic.ElabTerm

/-!
# The `applyWith` tactic
The `applyWith` tactic is like `apply`, but allows passing a custom configuration to the underlying
`apply` operation.
-/

namespace Mathlib.Tactic
open Lean Meta Elab Tactic Term

/--
`apply (config := cfg) e` is like `apply e` but allows you to provide a configuration
`cfg : ApplyConfig` to pass to the underlying `apply` operation.
-/
elab (name := applyWith) "apply" " (" &"config" " := " cfg:term ") " e:term : tactic => do
  let cfg ← unsafe evalTerm ApplyConfig (mkConst ``ApplyConfig) cfg
  evalApplyLikeTactic (·.apply · cfg) e

end Mathlib.Tactic
