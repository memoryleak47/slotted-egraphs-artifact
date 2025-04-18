import Mathlib.Testing.Egg.SimpOnlyOverride
/-
Copyright (c) 2022 Damiano Testa. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Damiano Testa
-/
import Mathlib.Algebra.Group.Opposite
import Mathlib.Algebra.Group.TypeTags

/-!
# Squares and even elements

This file defines square and even elements in a monoid.

## Main declarations

* `IsSquare a` means that there is some `r` such that `a = r * r`
* `Even a` means that there is some `r` such that `a = r + r`

## TODO

* Try to generalize `IsSquare/Even` lemmas further. For example, there are still a few lemmas in
  `Algebra.Ring.Parity` whose `Semiring` assumptions I (DT) am not convinced are necessary.
* The "old" definition of `Even a` asked for the existence of an element `c` such that `a = 2 * c`.
  For this reason, several fixes introduce an extra `two_mul` or `← two_mul`.
  It might be the case that by making a careful choice of `simp` lemma, this can be avoided.

## See also

`Mathlib.Algebra.Ring.Parity` for the definition of odd elements.
-/

assert_not_exists MonoidWithZero
assert_not_exists DenselyOrdered

open MulOpposite

variable {F α β : Type*}

section Mul
variable [Mul α]

/-- An element `a` of a type `α` with multiplication satisfies `IsSquare a` if `a = r * r`,
for some `r : α`. -/
@[to_additive "An element `a` of a type `α` with addition satisfies `Even a` if `a = r + r`,
for some `r : α`."]
def IsSquare (a : α) : Prop := ∃ r, a = r * r

@[to_additive (attr := simp)] lemma isSquare_mul_self (m : α) : IsSquare (m * m) := ⟨m, rfl⟩

@[to_additive]
lemma isSquare_op_iff {a : α} : IsSquare (op a) ↔ IsSquare a :=
  ⟨fun ⟨c, hc⟩ ↦ ⟨unop c, congr_arg unop hc⟩, fun ⟨c, hc⟩ ↦ ⟨op c, congr_arg op hc⟩⟩

@[to_additive]
lemma isSquare_unop_iff {a : αᵐᵒᵖ} : IsSquare (unop a) ↔ IsSquare a := isSquare_op_iff.symm

@[to_additive]
instance [DecidablePred (IsSquare : α → Prop)] : DecidablePred (IsSquare : αᵐᵒᵖ → Prop) :=
  fun _ ↦ decidable_of_iff _ isSquare_unop_iff

@[simp]
lemma even_ofMul_iff {a : α} : Even (Additive.ofMul a) ↔ IsSquare a := Iff.rfl

@[simp]
lemma isSquare_toMul_iff {a : Additive α} : IsSquare (Additive.toMul a) ↔ Even a := Iff.rfl

instance Additive.instDecidablePredEven [DecidablePred (IsSquare : α → Prop)] :
    DecidablePred (Even : Additive α → Prop) :=
  fun _ ↦ decidable_of_iff _ isSquare_toMul_iff

end Mul

section Add
variable [Add α]

@[simp] lemma isSquare_ofAdd_iff {a : α} : IsSquare (Multiplicative.ofAdd a) ↔ Even a := Iff.rfl

@[simp]
lemma even_toAdd_iff {a : Multiplicative α} : Even (Multiplicative.toAdd a) ↔ IsSquare a := Iff.rfl

instance Multiplicative.instDecidablePredIsSquare [DecidablePred (Even : α → Prop)] :
    DecidablePred (IsSquare : Multiplicative α → Prop) :=
  fun _ ↦ decidable_of_iff _ even_toAdd_iff

end Add

@[to_additive (attr := simp)]
lemma isSquare_one [MulOneClass α] : IsSquare (1 : α) := ⟨1, (mul_one _).symm⟩

@[to_additive]
lemma IsSquare.map [MulOneClass α] [MulOneClass β] [FunLike F α β] [MonoidHomClass F α β]
    {m : α} (f : F) :
    IsSquare m → IsSquare (f m) := by
  rintro ⟨m, rfl⟩
  exact ⟨f m, by simp⟩

section Monoid
variable [Monoid α] {n : ℕ} {a : α}

@[to_additive even_iff_exists_two_nsmul]
lemma isSquare_iff_exists_sq (m : α) : IsSquare m ↔ ∃ c, m = c ^ 2 := by simp [IsSquare, pow_two]

alias ⟨IsSquare.exists_sq, isSquare_of_exists_sq⟩ := isSquare_iff_exists_sq

attribute [to_additive Even.exists_two_nsmul
  "Alias of the forwards direction of `even_iff_exists_two_nsmul`."] IsSquare.exists_sq

@[to_additive] lemma IsSquare.pow (n : ℕ) : IsSquare a → IsSquare (a ^ n) := by
  rintro ⟨a, rfl⟩; exact ⟨a ^ n, (Commute.refl _).mul_pow _⟩

@[to_additive Even.nsmul'] lemma Even.isSquare_pow : Even n → ∀ a : α, IsSquare (a ^ n) := by
  rintro ⟨n, rfl⟩ a; exact ⟨a ^ n, pow_add _ _ _⟩

@[to_additive even_two_nsmul] lemma IsSquare_sq (a : α) : IsSquare (a ^ 2) := ⟨a, pow_two _⟩

end Monoid

@[to_additive]
lemma IsSquare.mul [CommSemigroup α] {a b : α} : IsSquare a → IsSquare b → IsSquare (a * b) := by
  rintro ⟨a, rfl⟩ ⟨b, rfl⟩; exact ⟨a * b, mul_mul_mul_comm _ _ _ _⟩

section DivisionMonoid
variable [DivisionMonoid α] {a : α}

@[to_additive (attr := simp)] lemma isSquare_inv : IsSquare a⁻¹ ↔ IsSquare a := by
  constructor <;> intro h
  · rw [← isSquare_op_iff, ← inv_inv a]
    exact h.map (MulEquiv.inv' α)
  · exact (isSquare_op_iff.mpr h).map (MulEquiv.inv' α).symm

alias ⟨_, IsSquare.inv⟩ := isSquare_inv

attribute [to_additive] IsSquare.inv

@[to_additive] lemma IsSquare.zpow (n : ℤ) : IsSquare a → IsSquare (a ^ n) := by
  rintro ⟨a, rfl⟩; exact ⟨a ^ n, (Commute.refl _).mul_zpow _⟩

end DivisionMonoid

@[to_additive]
lemma IsSquare.div [DivisionCommMonoid α] {a b : α} (ha : IsSquare a) (hb : IsSquare b) :
    IsSquare (a / b) := by rw [div_eq_mul_inv]; exact ha.mul hb.inv

@[to_additive (attr := simp) Even.zsmul']
lemma Even.isSquare_zpow [Group α] {n : ℤ} : Even n → ∀ a : α, IsSquare (a ^ n) := by
  rintro ⟨n, rfl⟩ a; exact ⟨a ^ n, zpow_add _ _ _⟩
