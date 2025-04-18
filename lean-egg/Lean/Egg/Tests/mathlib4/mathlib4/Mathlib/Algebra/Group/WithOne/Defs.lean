import Mathlib.Testing.Egg.SimpOnlyOverride
/-
Copyright (c) 2018 Mario Carneiro. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro, Johan Commelin
-/
import Mathlib.Algebra.Group.Defs
import Mathlib.Data.Option.Defs
import Mathlib.Logic.Nontrivial.Basic
import Mathlib.Tactic.Common

/-!
# Adjoining a zero/one to semigroups and related algebraic structures

This file contains different results about adjoining an element to an algebraic structure which then
behaves like a zero or a one. An example is adjoining a one to a semigroup to obtain a monoid. That
this provides an example of an adjunction is proved in
`Mathlib.Algebra.Category.MonCat.Adjunctions`.

Another result says that adjoining to a group an element `zero` gives a `GroupWithZero`. For more
information about these structures (which are not that standard in informal mathematics, see
`Mathlib.Algebra.GroupWithZero.Basic`)

## Porting notes

In Lean 3, we use `id` here and there to get correct types of proofs. This is required because
`WithOne` and `WithZero` are marked as `irreducible` at the end of
`Mathlib.Algebra.Group.WithOne.Defs`, so proofs that use `Option α` instead of `WithOne α` no
longer typecheck. In Lean 4, both types are plain `def`s, so we don't need these `id`s.

## TODO

`WithOne.coe_mul` and `WithZero.coe_mul` have inconsistent use of implicit parameters
-/

-- Check that we haven't needed to import all the basic lemmas about groups,
-- by asserting a random sample don't exist here:
assert_not_exists inv_involutive
assert_not_exists div_right_inj
assert_not_exists pow_ite

assert_not_exists MonoidWithZero
assert_not_exists DenselyOrdered

universe u v w

variable {α : Type u}

/-- Add an extra element `1` to a type -/
@[to_additive "Add an extra element `0` to a type"]
def WithOne (α) :=
  Option α

namespace WithOne

instance [Repr α] : Repr (WithZero α) :=
  ⟨fun o _ =>
    match o with
    | none => "0"
    | some a => "↑" ++ repr a⟩

@[to_additive]
instance [Repr α] : Repr (WithOne α) :=
  ⟨fun o _ =>
    match o with
    | none => "1"
    | some a => "↑" ++ repr a⟩

@[to_additive]
instance monad : Monad WithOne :=
  instMonadOption

@[to_additive]
instance one : One (WithOne α) :=
  ⟨none⟩

@[to_additive]
instance mul [Mul α] : Mul (WithOne α) :=
  ⟨Option.liftOrGet (· * ·)⟩

@[to_additive]
instance inv [Inv α] : Inv (WithOne α) :=
  ⟨fun a => Option.map Inv.inv a⟩

@[to_additive]
instance invOneClass [Inv α] : InvOneClass (WithOne α) :=
  { WithOne.one, WithOne.inv with inv_one := rfl }

@[to_additive]
instance inhabited : Inhabited (WithOne α) :=
  ⟨1⟩

@[to_additive]
instance nontrivial [Nonempty α] : Nontrivial (WithOne α) :=
  Option.nontrivial

-- Porting note: this new declaration is here to make `((a : α): WithOne α)` have type `WithOne α`;
-- otherwise the coercion kicks in and it becomes `Option.some a : WithOne α` which
-- becomes `Option.some a : Option α`.
/-- The canonical map from `α` into `WithOne α` -/
@[to_additive (attr := coe) "The canonical map from `α` into `WithZero α`"]
def coe : α → WithOne α :=
  Option.some

@[to_additive]
instance coeTC : CoeTC α (WithOne α) :=
  ⟨coe⟩

/-- Recursor for `WithOne` using the preferred forms `1` and `↑a`. -/
@[to_additive (attr := elab_as_elim, induction_eliminator, cases_eliminator)
  "Recursor for `WithZero` using the preferred forms `0` and `↑a`."]
def recOneCoe {C : WithOne α → Sort*} (h₁ : C 1) (h₂ : ∀ a : α, C a) : ∀ n : WithOne α, C n
  | Option.none => h₁
  | Option.some x => h₂ x

@[to_additive (attr := simp)]
lemma recOneCoe_one {C : WithOne α → Sort*} (h₁ h₂) :
    recOneCoe h₁ h₂ (1 : WithOne α) = (h₁ : C 1) :=
  rfl

@[to_additive (attr := simp)]
lemma recOneCoe_coe {C : WithOne α → Sort*} (h₁ h₂) (a : α) :
    recOneCoe h₁ h₂ (a : WithOne α) = (h₂ : ∀ a : α, C a) a :=
  rfl

/-- Deconstruct an `x : WithOne α` to the underlying value in `α`, given a proof that `x ≠ 1`. -/
@[to_additive unzero
      "Deconstruct an `x : WithZero α` to the underlying value in `α`, given a proof that `x ≠ 0`."]
def unone : ∀ {x : WithOne α}, x ≠ 1 → α | (x : α), _ => x

@[to_additive (attr := simp) unzero_coe]
theorem unone_coe {x : α} (hx : (x : WithOne α) ≠ 1) : unone hx = x :=
  rfl

@[to_additive (attr := simp) coe_unzero]
lemma coe_unone : ∀ {x : WithOne α} (hx : x ≠ 1), unone hx = x
  | (x : α), _ => rfl

-- Porting note: in Lean 4 the `some_eq_coe` lemmas present in the lean 3 version
-- of this file are syntactic tautologies

@[to_additive (attr := simp)]
theorem coe_ne_one {a : α} : (a : WithOne α) ≠ (1 : WithOne α) :=
  Option.some_ne_none a

@[to_additive (attr := simp)]
theorem one_ne_coe {a : α} : (1 : WithOne α) ≠ a :=
  coe_ne_one.symm

@[to_additive]
theorem ne_one_iff_exists {x : WithOne α} : x ≠ 1 ↔ ∃ a : α, ↑a = x :=
  Option.ne_none_iff_exists

@[to_additive]
instance canLift : CanLift (WithOne α) α (↑) fun a => a ≠ 1 where
  prf _ := ne_one_iff_exists.1

@[to_additive (attr := simp, norm_cast)]
theorem coe_inj {a b : α} : (a : WithOne α) = b ↔ a = b :=
  Option.some_inj

@[to_additive (attr := elab_as_elim)]
protected theorem cases_on {P : WithOne α → Prop} : ∀ x : WithOne α, P 1 → (∀ a : α, P a) → P x :=
  Option.casesOn

@[to_additive]
instance mulOneClass [Mul α] : MulOneClass (WithOne α) where
  mul := (· * ·)
  one := 1
  one_mul := (Option.liftOrGet_isId _).left_id
  mul_one := (Option.liftOrGet_isId _).right_id

@[to_additive (attr := simp, norm_cast)]
lemma coe_mul [Mul α] (a b : α) : (↑(a * b) : WithOne α) = a * b := rfl

@[to_additive]
instance monoid [Semigroup α] : Monoid (WithOne α) where
  __ := mulOneClass
  mul_assoc a b c := match a, b, c with
    | 1, b, c => by simp
    | (a : α), 1, c => by simp
    | (a : α), (b : α), 1 => by simp
    | (a : α), (b : α), (c : α) => by simp_rw [← coe_mul, mul_assoc]

@[to_additive]
instance commMonoid [CommSemigroup α] : CommMonoid (WithOne α) where
  mul_comm := fun a b => match a, b with
    | (a : α), (b : α) => congr_arg some (mul_comm a b)
    | (_ : α), 1 => rfl
    | 1, (_ : α) => rfl
    | 1, 1 => rfl

@[to_additive (attr := simp, norm_cast)]
theorem coe_inv [Inv α] (a : α) : ((a⁻¹ : α) : WithOne α) = (a : WithOne α)⁻¹ :=
  rfl

end WithOne
