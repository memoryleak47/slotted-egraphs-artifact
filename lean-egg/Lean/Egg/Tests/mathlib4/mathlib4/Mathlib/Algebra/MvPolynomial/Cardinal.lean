import Mathlib.Testing.Egg.SimpOnlyOverride
/-
Copyright (c) 2021 Chris Hughes, Junyan Xu. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Hughes, Junyan Xu
-/
import Mathlib.Algebra.MvPolynomial.Equiv
import Mathlib.Data.Finsupp.Fintype
import Mathlib.SetTheory.Cardinal.Finsupp

/-!
# Cardinality of Multivariate Polynomial Ring

The main result in this file is `MvPolynomial.cardinal_mk_le_max`, which says that
the cardinality of `MvPolynomial σ R` is bounded above by the maximum of `#R`, `#σ`
and `ℵ₀`.
-/


universe u v

open Cardinal

open Cardinal

namespace MvPolynomial

section TwoUniverses

variable {σ : Type u} {R : Type v} [CommSemiring R]

@[simp]
theorem cardinal_mk_eq_max_lift [Nonempty σ] [Nontrivial R] :
    #(MvPolynomial σ R) = max (max (Cardinal.lift.{u} #R) <| Cardinal.lift.{v} #σ) ℵ₀ :=
  (mk_finsupp_lift_of_infinite _ R).trans <| by
    rw [mk_finsupp_nat, max_assoc, lift_max, lift_aleph0, max_comm]

@[simp]
theorem cardinal_mk_eq_lift [IsEmpty σ] : #(MvPolynomial σ R) = Cardinal.lift.{u} #R :=
  ((isEmptyRingEquiv R σ).toEquiv.trans Equiv.ulift.{u}.symm).cardinal_eq

theorem cardinal_lift_mk_le_max {σ : Type u} {R : Type v} [CommSemiring R] : #(MvPolynomial σ R) ≤
    max (max (Cardinal.lift.{u} #R) <| Cardinal.lift.{v} #σ) ℵ₀ := by
  cases subsingleton_or_nontrivial R
  · exact (mk_eq_one _).trans_le (le_max_of_le_right one_le_aleph0)
  cases isEmpty_or_nonempty σ
  · exact cardinal_mk_eq_lift.trans_le (le_max_of_le_left <| le_max_left _ _)
  · exact cardinal_mk_eq_max_lift.le

end TwoUniverses

variable {σ R : Type u} [CommSemiring R]

theorem cardinal_mk_eq_max [Nonempty σ] [Nontrivial R] :
    #(MvPolynomial σ R) = max (max #R #σ) ℵ₀ := by simp

/-- The cardinality of the multivariate polynomial ring, `MvPolynomial σ R` is at most the maximum
of `#R`, `#σ` and `ℵ₀` -/
theorem cardinal_mk_le_max : #(MvPolynomial σ R) ≤ max (max #R #σ) ℵ₀ :=
  cardinal_lift_mk_le_max.trans <| by rw [lift_id, lift_id]

end MvPolynomial
