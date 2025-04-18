import Mathlib.Testing.Egg.SimpOnlyOverride
/-
Copyright (c) 2022 Kim Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kim Morrison
-/
import Mathlib.Algebra.Module.Defs
import Mathlib.Algebra.Algebra.Basic

/-!
# Additional facts about modules over algebras.
-/


namespace LinearMap

section RestrictScalars

variable (k : Type*) [CommSemiring k] (A : Type*) [Semiring A] [Algebra k A]
variable (M : Type*) [AddCommMonoid M] [Module k M] [Module A M] [IsScalarTower k A M]
variable (N : Type*) [AddCommMonoid N] [Module k N] [Module A N] [IsScalarTower k A N]

/-- Restriction of scalars for linear maps between modules over a `k`-algebra is itself `k`-linear.
-/
@[simps]
def restrictScalarsLinearMap : (M →ₗ[A] N) →ₗ[k] M →ₗ[k] N where
  toFun := LinearMap.restrictScalars k
  map_add' _ _ := rfl
  map_smul' _ _ := rfl

end RestrictScalars

end LinearMap
