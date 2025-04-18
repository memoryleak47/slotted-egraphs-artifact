import Mathlib.Testing.Egg.SimpOnlyOverride
/-
Copyright (c) 2014 Floris van Doorn (c) 2016 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Floris van Doorn, Leonardo de Moura, Jeremy Avigad, Mario Carneiro
-/
import Mathlib.Algebra.Group.Even
import Mathlib.Data.Nat.Sqrt

/-!
# The natural numbers form a monoid

This file contains the additive and multiplicative monoid instances on the natural numbers.

See note [foundational algebra order theory].
-/

assert_not_exists MonoidWithZero
assert_not_exists DenselyOrdered

open Multiplicative

namespace Nat

/-! ### Instances -/

instance instAddCancelCommMonoid : AddCancelCommMonoid ℕ where
  add := Nat.add
  add_assoc := Nat.add_assoc
  zero := Nat.zero
  zero_add := Nat.zero_add
  add_zero := Nat.add_zero
  add_comm := Nat.add_comm
  nsmul m n := m * n
  nsmul_zero := Nat.zero_mul
  nsmul_succ := succ_mul
  add_left_cancel _ _ _ := Nat.add_left_cancel

instance instCommMonoid : CommMonoid ℕ where
  mul := Nat.mul
  mul_assoc := Nat.mul_assoc
  one := Nat.succ Nat.zero
  one_mul := Nat.one_mul
  mul_one := Nat.mul_one
  mul_comm := Nat.mul_comm
  npow m n := n ^ m
  npow_zero := Nat.pow_zero
  npow_succ _ _ := rfl

/-!
### Extra instances to short-circuit type class resolution

These also prevent non-computable instances being used to construct these instances non-computably.
-/

instance instAddCommMonoid    : AddCommMonoid ℕ    := by infer_instance
instance instAddMonoid        : AddMonoid ℕ        := by infer_instance
instance instMonoid           : Monoid ℕ           := by infer_instance
instance instCommSemigroup    : CommSemigroup ℕ    := by infer_instance
instance instSemigroup        : Semigroup ℕ        := by infer_instance
instance instAddCommSemigroup : AddCommSemigroup ℕ := by infer_instance
instance instAddSemigroup     : AddSemigroup ℕ     := by infer_instance

/-! ### Miscellaneous lemmas -/

-- We want to use this lemma earlier than the lemmas simp can prove it with
@[simp, nolint simpNF] protected lemma nsmul_eq_mul (m n : ℕ) : m • n = m * n := rfl

section Multiplicative

lemma toAdd_pow (a : Multiplicative ℕ) (b : ℕ) : toAdd (a ^ b) = toAdd a * b := mul_comm _ _

@[simp] lemma ofAdd_mul (a b : ℕ) : ofAdd (a * b) = ofAdd a ^ b := (toAdd_pow _ _).symm

end Multiplicative

/-! #### Parity -/

variable {m n : ℕ}

lemma even_iff : Even n ↔ n % 2 = 0 where
  mp := fun ⟨m, hm⟩ ↦ by simp [← Nat.two_mul, hm]
  mpr h := ⟨n / 2, (mod_add_div n 2).symm.trans (by simp [← Nat.two_mul, h])⟩

instance : DecidablePred (Even : ℕ → Prop) := fun _ ↦ decidable_of_iff _ even_iff.symm

/-- `IsSquare` can be decided on `ℕ` by checking against the square root. -/
instance : DecidablePred (IsSquare : ℕ → Prop) :=
  fun m ↦ decidable_of_iff' (Nat.sqrt m * Nat.sqrt m = m) <| by
    simp_rw [← Nat.exists_mul_self m, IsSquare, eq_comm]

lemma not_even_iff : ¬ Even n ↔ n % 2 = 1 := by rw [even_iff, mod_two_ne_zero]

@[simp] lemma two_dvd_ne_zero : ¬2 ∣ n ↔ n % 2 = 1 :=
  (even_iff_exists_two_nsmul _).symm.not.trans not_even_iff

@[simp] lemma not_even_one : ¬Even 1 := by simp [even_iff]

@[parity_simps] lemma even_add : Even (m + n) ↔ (Even m ↔ Even n) := by
  rcases mod_two_eq_zero_or_one m with h₁ | h₁ <;> rcases mod_two_eq_zero_or_one n with h₂ | h₂ <;>
    simp [even_iff, h₁, h₂, Nat.add_mod]

@[parity_simps] lemma even_add_one : Even (n + 1) ↔ ¬Even n := by simp [even_add]

lemma succ_mod_two_eq_zero_iff {m : ℕ} : (m + 1) % 2 = 0 ↔ m % 2 = 1 := by
  simp [← Nat.even_iff, ← Nat.not_even_iff, parity_simps]

lemma succ_mod_two_eq_one_iff {m : ℕ} : (m + 1) % 2 = 1 ↔ m % 2 = 0 := by
  simp [← Nat.even_iff, ← Nat.not_even_iff, parity_simps]

lemma two_not_dvd_two_mul_add_one (n : ℕ) : ¬2 ∣ 2 * n + 1 := by simp [add_mod]

lemma two_not_dvd_two_mul_sub_one : ∀ {n}, 0 < n → ¬2 ∣ 2 * n - 1
  | n + 1, _ => two_not_dvd_two_mul_add_one n

@[parity_simps] lemma even_sub (h : n ≤ m) : Even (m - n) ↔ (Even m ↔ Even n) := by
  conv_rhs => rw [← Nat.sub_add_cancel h, even_add]
  by_cases h : Even n <;> simp [h]

@[parity_simps] lemma even_mul : Even (m * n) ↔ Even m ∨ Even n := by
  rcases mod_two_eq_zero_or_one m with h₁ | h₁ <;> rcases mod_two_eq_zero_or_one n with h₂ | h₂ <;>
    simp [even_iff, h₁, h₂, Nat.mul_mod]

/-- If `m` and `n` are natural numbers, then the natural number `m^n` is even
if and only if `m` is even and `n` is positive. -/
@[parity_simps] lemma even_pow : Even (m ^ n) ↔ Even m ∧ n ≠ 0 := by
  induction n <;> simp (config := { contextual := true }) [*, pow_succ', even_mul]

lemma even_pow' (h : n ≠ 0) : Even (m ^ n) ↔ Even m := even_pow.trans <| and_iff_left h

lemma even_mul_succ_self (n : ℕ) : Even (n * (n + 1)) := by rw [even_mul, even_add_one]; exact em _

lemma even_mul_pred_self : ∀ n : ℕ, Even (n * (n - 1))
  | 0 => even_zero
  | (n + 1) => mul_comm (n + 1 - 1) (n + 1) ▸ even_mul_succ_self n

@[deprecated (since := "2024-01-20")] alias even_mul_self_pred := even_mul_pred_self

lemma two_mul_div_two_of_even : Even n → 2 * (n / 2) = n := fun h ↦
  Nat.mul_div_cancel_left' ((even_iff_exists_two_nsmul _).1 h)

lemma div_two_mul_two_of_even : Even n → n / 2 * 2 = n :=
  fun h ↦ Nat.div_mul_cancel ((even_iff_exists_two_nsmul _).1 h)

-- Here are examples of how `parity_simps` can be used with `Nat`.
example (m n : ℕ) (h : Even m) : ¬Even (n + 3) ↔ Even (m ^ 2 + m + n) := by simp [*, parity_simps]

-- Porting note: the `simp` lemmas about `bit*` no longer apply.
example : ¬Even 25394535 := by decide

/-! #### Units -/

lemma units_eq_one (u : ℕˣ) : u = 1 := Units.ext <| Nat.eq_one_of_dvd_one ⟨u.inv, u.val_inv.symm⟩

lemma addUnits_eq_zero (u : AddUnits ℕ) : u = 0 :=
  AddUnits.ext <| (Nat.eq_zero_of_add_eq_zero u.val_neg).1

@[simp] protected lemma isUnit_iff {n : ℕ} : IsUnit n ↔ n = 1 where
  mp := by rintro ⟨u, rfl⟩; obtain rfl := Nat.units_eq_one u; rfl
  mpr h := h.symm ▸ ⟨1, rfl⟩

instance unique_units : Unique ℕˣ where
  default := 1
  uniq := Nat.units_eq_one

instance unique_addUnits : Unique (AddUnits ℕ) where
  default := 0
  uniq := Nat.addUnits_eq_zero

end Nat
