import Mathlib.Testing.Egg.SimpOnlyOverride
/-
Copyright (c) 2020 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov
-/
import Mathlib.Algebra.Group.Action.Opposite
import Mathlib.Algebra.Group.Int
import Mathlib.Algebra.Group.Nat
import Mathlib.Logic.Function.Iterate
import Mathlib.Tactic.Common

/-!
# Iterates of monoid homomorphisms

Iterate of a monoid homomorphism is a monoid homomorphism but it has a wrong type, so Lean
can't apply lemmas like `MonoidHom.map_one` to `f^[n] 1`. Though it is possible to define
a monoid structure on the endomorphisms, quite often we do not want to convert from
`M →* M` to `Monoid.End M` and from `f^[n]` to `f^n` just to apply a simple lemma.

So, we restate standard `map_*` lemmas under names `iterate_map_*`.

We also prove formulas for iterates of add/mul left/right.

## Tags

homomorphism, iterate
-/

assert_not_exists MonoidWithZero
assert_not_exists DenselyOrdered

open Function

variable {M : Type*} {G : Type*} {H : Type*}

/-- An auxiliary lemma that can be used to prove `⇑(f ^ n) = ⇑f^[n]`. -/
theorem hom_coe_pow {F : Type*} [Monoid F] (c : F → M → M) (h1 : c 1 = id)
    (hmul : ∀ f g, c (f * g) = c f ∘ c g) (f : F) : ∀ n, c (f ^ n) = (c f)^[n]
  | 0 => by
    rw [pow_zero, h1]
    rfl
  | n + 1 => by rw [pow_succ, iterate_succ, hmul, hom_coe_pow c h1 hmul f n]

@[to_additive (attr := simp)]
theorem iterate_map_mul {M F : Type*} [Mul M] [FunLike F M M] [MulHomClass F M M]
    (f : F) (n : ℕ) (x y : M) :
    f^[n] (x * y) = f^[n] x * f^[n] y :=
  Function.Semiconj₂.iterate (map_mul f) n x y

@[to_additive (attr := simp)]
theorem iterate_map_one {M F : Type*} [One M] [FunLike F M M] [OneHomClass F M M]
    (f : F) (n : ℕ) :
    f^[n] 1 = 1 :=
  iterate_fixed (map_one f) n

@[to_additive (attr := simp)]
theorem iterate_map_inv {M F : Type*} [Group M] [FunLike F M M] [MonoidHomClass F M M]
    (f : F) (n : ℕ) (x : M) :
    f^[n] x⁻¹ = (f^[n] x)⁻¹ :=
  Commute.iterate_left (map_inv f) n x

@[to_additive (attr := simp)]
theorem iterate_map_div {M F : Type*} [Group M] [FunLike F M M] [MonoidHomClass F M M]
    (f : F) (n : ℕ) (x y : M) :
    f^[n] (x / y) = f^[n] x / f^[n] y :=
  Semiconj₂.iterate (map_div f) n x y

@[to_additive (attr := simp)]
theorem iterate_map_pow {M F : Type*} [Monoid M] [FunLike F M M] [MonoidHomClass F M M]
    (f : F) (n : ℕ) (x : M) (k : ℕ) :
    f^[n] (x ^ k) = f^[n] x ^ k :=
  Commute.iterate_left (map_pow f · k) n x

@[to_additive (attr := simp)]
theorem iterate_map_zpow {M F : Type*} [Group M] [FunLike F M M] [MonoidHomClass F M M]
    (f : F) (n : ℕ) (x : M) (k : ℤ) :
    f^[n] (x ^ k) = f^[n] x ^ k :=
  Commute.iterate_left (map_zpow f · k) n x

--what should be the namespace for this section?
section Monoid

variable [Monoid G] (a : G) (n : ℕ)

@[to_additive (attr := simp)]
theorem smul_iterate [MulAction G H] : (a • · : H → H)^[n] = (a ^ n • ·) :=
  funext fun b =>
    Nat.recOn n (by rw [iterate_zero, id, pow_zero, one_smul])
    fun n ih => by rw [iterate_succ', comp_apply, ih, pow_succ', mul_smul]

@[to_additive]
lemma smul_iterate_apply [MulAction G H] {b : H} : (a • ·)^[n] b = a ^ n • b := by
  rw [smul_iterate]

@[to_additive (attr := simp)]
theorem mul_left_iterate : (a * ·)^[n] = (a ^ n * ·) :=
  smul_iterate a n

@[to_additive (attr := simp)]
theorem mul_right_iterate : (· * a)^[n] = (· * a ^ n) :=
  smul_iterate (MulOpposite.op a) n

@[to_additive]
theorem mul_right_iterate_apply_one : (· * a)^[n] 1 = a ^ n := by simp [mul_right_iterate]

@[to_additive (attr := simp)]
theorem pow_iterate (n : ℕ) (j : ℕ) : (fun x : G => x ^ n)^[j] = fun x : G => x ^ n ^ j :=
  letI : MulAction ℕ G :=
    { smul := fun n g => g ^ n
      one_smul := pow_one
      mul_smul := fun m n g => pow_mul' g m n }
  smul_iterate n j

end Monoid

section Group

variable [Group G]

@[to_additive (attr := simp)]
theorem zpow_iterate (n : ℤ) (j : ℕ) : (fun x : G => x ^ n)^[j] = fun x => x ^ n ^ j :=
  letI : MulAction ℤ G :=
    { smul := fun n g => g ^ n
      one_smul := zpow_one
      mul_smul := fun m n g => zpow_mul' g m n }
  smul_iterate n j

end Group

section Semigroup

variable [Semigroup G] {a b c : G}

-- Porting note(#12129): additional beta reduction needed
-- see also https://leanprover.zulipchat.com/#narrow/stream/
-- 287929-mathlib4/topic/dsimp.20before.20rw/near/317063489
@[to_additive]
theorem SemiconjBy.function_semiconj_mul_left (h : SemiconjBy a b c) :
    Function.Semiconj (a * ·) (b * ·) (c * ·) := fun j => by
  beta_reduce; rw [← mul_assoc, h.eq, mul_assoc]

@[to_additive]
theorem Commute.function_commute_mul_left (h : Commute a b) :
    Function.Commute (a * ·) (b * ·) :=
  SemiconjBy.function_semiconj_mul_left h

@[to_additive]
theorem SemiconjBy.function_semiconj_mul_right_swap (h : SemiconjBy a b c) :
    Function.Semiconj (· * a) (· * c) (· * b) := fun j => by simp_rw [mul_assoc, ← h.eq]

@[to_additive]
theorem Commute.function_commute_mul_right (h : Commute a b) :
    Function.Commute (· * a) (· * b) :=
  SemiconjBy.function_semiconj_mul_right_swap h

end Semigroup
