import Mathlib.Testing.Egg.SimpOnlyOverride
/-
Copyright (c) 2019 Kenny Lau. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kenny Lau
-/
import Mathlib.Algebra.PUnitInstances.Algebra
import Mathlib.Algebra.Module.Defs
import Mathlib.Algebra.Ring.Action.Basic

/-!
# Instances on PUnit

This file collects facts about module structures on the one-element type
-/

namespace PUnit

variable {R S : Type*}

@[to_additive]
instance smul : SMul R PUnit :=
  ⟨fun _ _ => unit⟩

@[to_additive (attr := simp)]
theorem smul_eq {R : Type*} (y : PUnit) (r : R) : r • y = unit :=
  rfl

@[to_additive]
instance : IsCentralScalar R PUnit :=
  ⟨fun _ _ => rfl⟩

@[to_additive]
instance : SMulCommClass R S PUnit :=
  ⟨fun _ _ _ => rfl⟩

@[to_additive]
instance instIsScalarTowerOfSMul [SMul R S] : IsScalarTower R S PUnit :=
  ⟨fun _ _ _ => rfl⟩

instance smulWithZero [Zero R] : SMulWithZero R PUnit where
  __ := PUnit.smul
  smul_zero := by subsingleton
  zero_smul := by subsingleton

instance mulAction [Monoid R] : MulAction R PUnit where
  __ := PUnit.smul
  one_smul := by subsingleton
  mul_smul := by subsingleton

instance distribMulAction [Monoid R] : DistribMulAction R PUnit where
  __ := PUnit.mulAction
  smul_zero := by subsingleton
  smul_add := by subsingleton

instance mulDistribMulAction [Monoid R] : MulDistribMulAction R PUnit where
  __ := PUnit.mulAction
  smul_mul := by subsingleton
  smul_one := by subsingleton

instance mulSemiringAction [Semiring R] : MulSemiringAction R PUnit :=
  { PUnit.distribMulAction, PUnit.mulDistribMulAction with }

instance mulActionWithZero [MonoidWithZero R] : MulActionWithZero R PUnit :=
  { PUnit.mulAction, PUnit.smulWithZero with }

instance module [Semiring R] : Module R PUnit where
  __ := PUnit.distribMulAction
  add_smul := by subsingleton
  zero_smul := by subsingleton

end PUnit
