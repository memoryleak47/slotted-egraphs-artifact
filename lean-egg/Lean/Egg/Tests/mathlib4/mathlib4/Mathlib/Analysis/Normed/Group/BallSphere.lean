import Mathlib.Testing.Egg.SimpOnlyOverride
/-
Copyright (c) 2022 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov, Heather Macbeth
-/
import Mathlib.Analysis.Normed.Group.Uniform

/-!
# Negation on spheres and balls

In this file we define `InvolutiveNeg` and `ContinuousNeg` instances for spheres, open balls, and
closed balls in a semi normed group.
-/


open Metric Set

variable {E : Type*} [i : SeminormedAddCommGroup E] {r : ℝ}

/-- We equip the sphere, in a seminormed group, with a formal operation of negation, namely the
antipodal map. -/
instance : InvolutiveNeg (sphere (0 : E) r) where
  neg := Subtype.map Neg.neg fun w => by simp
  neg_neg x := Subtype.ext <| neg_neg x.1

@[simp]
theorem coe_neg_sphere {r : ℝ} (v : sphere (0 : E) r) : ↑(-v) = (-v : E) :=
  rfl

instance : ContinuousNeg (sphere (0 : E) r) := IsInducing.subtypeVal.continuousNeg fun _ => rfl

/-- We equip the ball, in a seminormed group, with a formal operation of negation, namely the
antipodal map. -/
instance {r : ℝ} : InvolutiveNeg (ball (0 : E) r) where
  neg := Subtype.map Neg.neg fun w => by simp
  neg_neg x := Subtype.ext <| neg_neg x.1

@[simp] theorem coe_neg_ball {r : ℝ} (v : ball (0 : E) r) : ↑(-v) = (-v : E) := rfl

instance : ContinuousNeg (ball (0 : E) r) := IsInducing.subtypeVal.continuousNeg fun _ => rfl

/-- We equip the closed ball, in a seminormed group, with a formal operation of negation, namely the
antipodal map. -/
instance {r : ℝ} : InvolutiveNeg (closedBall (0 : E) r) where
  neg := Subtype.map Neg.neg fun w => by simp
  neg_neg x := Subtype.ext <| neg_neg x.1

@[simp] theorem coe_neg_closedBall {r : ℝ} (v : closedBall (0 : E) r) : ↑(-v) = (-v : E) := rfl

instance : ContinuousNeg (closedBall (0 : E) r) := IsInducing.subtypeVal.continuousNeg  fun _ => rfl
