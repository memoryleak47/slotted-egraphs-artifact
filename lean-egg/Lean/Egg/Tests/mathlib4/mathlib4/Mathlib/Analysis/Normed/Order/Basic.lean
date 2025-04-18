import Mathlib.Testing.Egg.SimpOnlyOverride
/-
Copyright (c) 2020 Anatole Dedecker. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Anatole Dedecker, Yaël Dillies
-/
import Mathlib.Algebra.Order.Group.TypeTags
import Mathlib.Analysis.Normed.Field.Lemmas

/-!
# Ordered normed spaces

In this file, we define classes for fields and groups that are both normed and ordered.
These are mostly useful to avoid diamonds during type class inference.
-/


open Filter Set

open Topology

variable {α : Type*}

/-- A `NormedOrderedAddGroup` is an additive group that is both a `NormedAddCommGroup` and an
`OrderedAddCommGroup`. This class is necessary to avoid diamonds caused by both classes
carrying their own group structure. -/
class NormedOrderedAddGroup (α : Type*) extends OrderedAddCommGroup α, Norm α, MetricSpace α where
  /-- The distance function is induced by the norm. -/
  dist_eq : ∀ x y, dist x y = ‖x - y‖ := by aesop

/-- A `NormedOrderedGroup` is a group that is both a `NormedCommGroup` and an
`OrderedCommGroup`. This class is necessary to avoid diamonds caused by both classes
carrying their own group structure. -/
@[to_additive]
class NormedOrderedGroup (α : Type*) extends OrderedCommGroup α, Norm α, MetricSpace α where
  /-- The distance function is induced by the norm. -/
  dist_eq : ∀ x y, dist x y = ‖x / y‖ := by aesop

/-- A `NormedLinearOrderedAddGroup` is an additive group that is both a `NormedAddCommGroup`
and a `LinearOrderedAddCommGroup`. This class is necessary to avoid diamonds caused by both
classes carrying their own group structure. -/
class NormedLinearOrderedAddGroup (α : Type*) extends LinearOrderedAddCommGroup α, Norm α,
  MetricSpace α where
  /-- The distance function is induced by the norm. -/
  dist_eq : ∀ x y, dist x y = ‖x - y‖ := by aesop

/-- A `NormedLinearOrderedGroup` is a group that is both a `NormedCommGroup` and a
`LinearOrderedCommGroup`. This class is necessary to avoid diamonds caused by both classes
carrying their own group structure. -/
@[to_additive]
class NormedLinearOrderedGroup (α : Type*) extends LinearOrderedCommGroup α, Norm α,
  MetricSpace α where
  /-- The distance function is induced by the norm. -/
  dist_eq : ∀ x y, dist x y = ‖x / y‖ := by aesop

/-- A `NormedLinearOrderedField` is a field that is both a `NormedField` and a
    `LinearOrderedField`. This class is necessary to avoid diamonds. -/
class NormedLinearOrderedField (α : Type*) extends LinearOrderedField α, Norm α,
  MetricSpace α where
  /-- The distance function is induced by the norm. -/
  dist_eq : ∀ x y, dist x y = ‖x - y‖ := by aesop
  /-- The norm is multiplicative. -/
  norm_mul' : ∀ x y : α, ‖x * y‖ = ‖x‖ * ‖y‖

@[to_additive]
instance (priority := 100) NormedOrderedGroup.toNormedCommGroup [NormedOrderedGroup α] :
    NormedCommGroup α :=
  ⟨NormedOrderedGroup.dist_eq⟩

@[to_additive]
instance (priority := 100) NormedLinearOrderedGroup.toNormedOrderedGroup
    [NormedLinearOrderedGroup α] : NormedOrderedGroup α :=
  ⟨NormedLinearOrderedGroup.dist_eq⟩

instance (priority := 100) NormedLinearOrderedField.toNormedField (α : Type*)
    [NormedLinearOrderedField α] : NormedField α where
  dist_eq := NormedLinearOrderedField.dist_eq
  norm_mul' := NormedLinearOrderedField.norm_mul'

instance Rat.normedLinearOrderedField : NormedLinearOrderedField ℚ :=
  ⟨dist_eq_norm, norm_mul⟩

noncomputable instance Real.normedLinearOrderedField : NormedLinearOrderedField ℝ :=
  ⟨dist_eq_norm, norm_mul⟩

@[to_additive]
instance OrderDual.normedOrderedGroup [NormedOrderedGroup α] : NormedOrderedGroup αᵒᵈ :=
  { @NormedOrderedGroup.toNormedCommGroup α _, OrderDual.orderedCommGroup with }

@[to_additive]
instance OrderDual.normedLinearOrderedGroup [NormedLinearOrderedGroup α] :
    NormedLinearOrderedGroup αᵒᵈ :=
  { OrderDual.normedOrderedGroup, OrderDual.instLinearOrder _ with }

instance Additive.normedOrderedAddGroup [NormedOrderedGroup α] :
    NormedOrderedAddGroup (Additive α) :=
  { Additive.normedAddCommGroup, Additive.orderedAddCommGroup with }

instance Multiplicative.normedOrderedGroup [NormedOrderedAddGroup α] :
    NormedOrderedGroup (Multiplicative α) :=
  { Multiplicative.normedCommGroup, Multiplicative.orderedCommGroup with }

instance Additive.normedLinearOrderedAddGroup [NormedLinearOrderedGroup α] :
    NormedLinearOrderedAddGroup (Additive α) :=
  { Additive.normedAddCommGroup, Additive.linearOrderedAddCommGroup with }

instance Multiplicative.normedlinearOrderedGroup [NormedLinearOrderedAddGroup α] :
    NormedLinearOrderedGroup (Multiplicative α) :=
  { Multiplicative.normedCommGroup, Multiplicative.linearOrderedCommGroup with }
