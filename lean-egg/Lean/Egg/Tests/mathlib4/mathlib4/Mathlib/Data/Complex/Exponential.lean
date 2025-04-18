import Mathlib.Testing.Egg.SimpOnlyOverride
/-
Copyright (c) 2018 Chris Hughes. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Hughes, Abhimanyu Pallavi Sudhir
-/
import Mathlib.Algebra.Order.CauSeq.BigOperators
import Mathlib.Algebra.Order.Star.Basic
import Mathlib.Data.Complex.Abs
import Mathlib.Data.Complex.BigOperators
import Mathlib.Data.Nat.Choose.Sum
import Mathlib.Tactic.Bound.Attribute

/-!
# Exponential, trigonometric and hyperbolic trigonometric functions

This file contains the definitions of the real and complex exponential, sine, cosine, tangent,
hyperbolic sine, hyperbolic cosine, and hyperbolic tangent functions.

-/

open CauSeq Finset IsAbsoluteValue
open scoped ComplexConjugate

namespace Complex

theorem isCauSeq_abs_exp (z : ℂ) :
    IsCauSeq _root_.abs fun n => ∑ m ∈ range n, abs (z ^ m / m.factorial) :=
  let ⟨n, hn⟩ := exists_nat_gt (abs z)
  have hn0 : (0 : ℝ) < n := lt_of_le_of_lt (abs.nonneg _) hn
  IsCauSeq.series_ratio_test n (abs z / n) (div_nonneg (abs.nonneg _) (le_of_lt hn0))
    (by rwa [div_lt_iff₀ hn0, one_mul]) fun m hm => by
      rw [abs_abs, abs_abs, Nat.factorial_succ, pow_succ', mul_comm m.succ, Nat.cast_mul, ← div_div,
        mul_div_assoc, mul_div_right_comm, map_mul, map_div₀, abs_natCast]
      gcongr
      exact le_trans hm (Nat.le_succ _)

noncomputable section

theorem isCauSeq_exp (z : ℂ) : IsCauSeq abs fun n => ∑ m ∈ range n, z ^ m / m.factorial :=
  (isCauSeq_abs_exp z).of_abv

/-- The Cauchy sequence consisting of partial sums of the Taylor series of
the complex exponential function -/
@[pp_nodot]
def exp' (z : ℂ) : CauSeq ℂ Complex.abs :=
  ⟨fun n => ∑ m ∈ range n, z ^ m / m.factorial, isCauSeq_exp z⟩

/-- The complex exponential function, defined via its Taylor series -/
-- Porting note: removed `irreducible` attribute, so I can prove things
@[pp_nodot]
def exp (z : ℂ) : ℂ :=
  CauSeq.lim (exp' z)

/-- The complex sine function, defined via `exp` -/
@[pp_nodot]
def sin (z : ℂ) : ℂ :=
  (exp (-z * I) - exp (z * I)) * I / 2

/-- The complex cosine function, defined via `exp` -/
@[pp_nodot]
def cos (z : ℂ) : ℂ :=
  (exp (z * I) + exp (-z * I)) / 2

/-- The complex tangent function, defined as `sin z / cos z` -/
@[pp_nodot]
def tan (z : ℂ) : ℂ :=
  sin z / cos z

/-- The complex cotangent function, defined as `cos z / sin z` -/
def cot (z : ℂ) : ℂ :=
  cos z / sin z

/-- The complex hyperbolic sine function, defined via `exp` -/
@[pp_nodot]
def sinh (z : ℂ) : ℂ :=
  (exp z - exp (-z)) / 2

/-- The complex hyperbolic cosine function, defined via `exp` -/
@[pp_nodot]
def cosh (z : ℂ) : ℂ :=
  (exp z + exp (-z)) / 2

/-- The complex hyperbolic tangent function, defined as `sinh z / cosh z` -/
@[pp_nodot]
def tanh (z : ℂ) : ℂ :=
  sinh z / cosh z

/-- scoped notation for the complex exponential function -/
scoped notation "cexp" => Complex.exp

end

end Complex

namespace Real

open Complex

noncomputable section

/-- The real exponential function, defined as the real part of the complex exponential -/
@[pp_nodot]
nonrec def exp (x : ℝ) : ℝ :=
  (exp x).re

/-- The real sine function, defined as the real part of the complex sine -/
@[pp_nodot]
nonrec def sin (x : ℝ) : ℝ :=
  (sin x).re

/-- The real cosine function, defined as the real part of the complex cosine -/
@[pp_nodot]
nonrec def cos (x : ℝ) : ℝ :=
  (cos x).re

/-- The real tangent function, defined as the real part of the complex tangent -/
@[pp_nodot]
nonrec def tan (x : ℝ) : ℝ :=
  (tan x).re

/-- The real cotangent function, defined as the real part of the complex cotangent -/
nonrec def cot (x : ℝ) : ℝ :=
  (cot x).re

/-- The real hypebolic sine function, defined as the real part of the complex hyperbolic sine -/
@[pp_nodot]
nonrec def sinh (x : ℝ) : ℝ :=
  (sinh x).re

/-- The real hypebolic cosine function, defined as the real part of the complex hyperbolic cosine -/
@[pp_nodot]
nonrec def cosh (x : ℝ) : ℝ :=
  (cosh x).re

/-- The real hypebolic tangent function, defined as the real part of
the complex hyperbolic tangent -/
@[pp_nodot]
nonrec def tanh (x : ℝ) : ℝ :=
  (tanh x).re

/-- scoped notation for the real exponential function -/
scoped notation "rexp" => Real.exp

end

end Real

namespace Complex

variable (x y : ℂ)

@[simp]
theorem exp_zero : exp 0 = 1 := by
  rw [exp]
  refine lim_eq_of_equiv_const fun ε ε0 => ⟨1, fun j hj => ?_⟩
  convert (config := .unfoldSameFun) ε0 -- Porting note: ε0 : ε > 0 but goal is _ < ε
  cases' j with j j
  · exact absurd hj (not_le_of_gt zero_lt_one)
  · dsimp [exp']
    induction' j with j ih
    · dsimp [exp']; simp [show Nat.succ 0 = 1 from rfl]
    · rw [← ih (by simp [Nat.succ_le_succ])]
      simp only [sum_range_succ, pow_succ]
      simp

theorem exp_add : exp (x + y) = exp x * exp y := by
  have hj : ∀ j : ℕ, (∑ m ∈ range j, (x + y) ^ m / m.factorial) =
        ∑ i ∈ range j, ∑ k ∈ range (i + 1), x ^ k / k.factorial *
          (y ^ (i - k) / (i - k).factorial) := by
    intro j
    refine Finset.sum_congr rfl fun m _ => ?_
    rw [add_pow, div_eq_mul_inv, sum_mul]
    refine Finset.sum_congr rfl fun I hi => ?_
    have h₁ : (m.choose I : ℂ) ≠ 0 :=
      Nat.cast_ne_zero.2 (pos_iff_ne_zero.1 (Nat.choose_pos (Nat.le_of_lt_succ (mem_range.1 hi))))
    have h₂ := Nat.choose_mul_factorial_mul_factorial (Nat.le_of_lt_succ <| Finset.mem_range.1 hi)
    rw [← h₂, Nat.cast_mul, Nat.cast_mul, mul_inv, mul_inv]
    simp only [mul_left_comm (m.choose I : ℂ), mul_assoc, mul_left_comm (m.choose I : ℂ)⁻¹,
      mul_comm (m.choose I : ℂ)]
    rw [inv_mul_cancel₀ h₁]
    simp [div_eq_mul_inv, mul_comm, mul_assoc, mul_left_comm]
  simp_rw [exp, exp', lim_mul_lim]
  apply (lim_eq_lim_of_equiv _).symm
  simp only [hj]
  exact cauchy_product (isCauSeq_abs_exp x) (isCauSeq_exp y)

-- Porting note (#11445): new definition
/-- the exponential function as a monoid hom from `Multiplicative ℂ` to `ℂ` -/
@[simps]
noncomputable def expMonoidHom : MonoidHom (Multiplicative ℂ) ℂ :=
  { toFun := fun z => exp (Multiplicative.toAdd z),
    map_one' := by simp,
    map_mul' := by simp [exp_add] }

theorem exp_list_sum (l : List ℂ) : exp l.sum = (l.map exp).prod :=
  map_list_prod (M := Multiplicative ℂ) expMonoidHom l

theorem exp_multiset_sum (s : Multiset ℂ) : exp s.sum = (s.map exp).prod :=
  @MonoidHom.map_multiset_prod (Multiplicative ℂ) ℂ _ _ expMonoidHom s

theorem exp_sum {α : Type*} (s : Finset α) (f : α → ℂ) :
    exp (∑ x ∈ s, f x) = ∏ x ∈ s, exp (f x) :=
  map_prod (β := Multiplicative ℂ) expMonoidHom f s

lemma exp_nsmul (x : ℂ) (n : ℕ) : exp (n • x) = exp x ^ n :=
  @MonoidHom.map_pow (Multiplicative ℂ) ℂ _ _  expMonoidHom _ _

theorem exp_nat_mul (x : ℂ) : ∀ n : ℕ, exp (n * x) = exp x ^ n
  | 0 => by rw [Nat.cast_zero, zero_mul, exp_zero, pow_zero]
  | Nat.succ n => by rw [pow_succ, Nat.cast_add_one, add_mul, exp_add, ← exp_nat_mul _ n, one_mul]

@[simp]
theorem exp_ne_zero : exp x ≠ 0 := fun h =>
  zero_ne_one (α := ℂ) <| by rw [← exp_zero, ← add_neg_cancel x, exp_add, h]; simp

theorem exp_neg : exp (-x) = (exp x)⁻¹ := by
  rw [← mul_right_inj' (exp_ne_zero x), ← exp_add]; simp [mul_inv_cancel₀ (exp_ne_zero x)]

theorem exp_sub : exp (x - y) = exp x / exp y := by
  simp [sub_eq_add_neg, exp_add, exp_neg, div_eq_mul_inv]

theorem exp_int_mul (z : ℂ) (n : ℤ) : Complex.exp (n * z) = Complex.exp z ^ n := by
  cases n
  · simp [exp_nat_mul]
  · simp [exp_add, add_mul, pow_add, exp_neg, exp_nat_mul]

@[simp]
theorem exp_conj : exp (conj x) = conj (exp x) := by
  dsimp [exp]
  rw [← lim_conj]
  refine congr_arg CauSeq.lim (CauSeq.ext fun _ => ?_)
  dsimp [exp', Function.comp_def, cauSeqConj]
  rw [map_sum (starRingEnd _)]
  refine sum_congr rfl fun n _ => ?_
  rw [map_div₀, map_pow, ← ofReal_natCast, conj_ofReal]

@[simp]
theorem ofReal_exp_ofReal_re (x : ℝ) : ((exp x).re : ℂ) = exp x :=
  conj_eq_iff_re.1 <| by rw [← exp_conj, conj_ofReal]

@[simp, norm_cast]
theorem ofReal_exp (x : ℝ) : (Real.exp x : ℂ) = exp x :=
  ofReal_exp_ofReal_re _

@[simp]
theorem exp_ofReal_im (x : ℝ) : (exp x).im = 0 := by rw [← ofReal_exp_ofReal_re, ofReal_im]

theorem exp_ofReal_re (x : ℝ) : (exp x).re = Real.exp x :=
  rfl

theorem two_sinh : 2 * sinh x = exp x - exp (-x) :=
  mul_div_cancel₀ _ two_ne_zero

theorem two_cosh : 2 * cosh x = exp x + exp (-x) :=
  mul_div_cancel₀ _ two_ne_zero

@[simp]
theorem sinh_zero : sinh 0 = 0 := by simp [sinh]

@[simp]
theorem sinh_neg : sinh (-x) = -sinh x := by simp [sinh, exp_neg, (neg_div _ _).symm, add_mul]

private theorem sinh_add_aux {a b c d : ℂ} :
    (a - b) * (c + d) + (a + b) * (c - d) = 2 * (a * c - b * d) := by ring

theorem sinh_add : sinh (x + y) = sinh x * cosh y + cosh x * sinh y := by
  rw [← mul_right_inj' (two_ne_zero' ℂ), two_sinh, exp_add, neg_add, exp_add, eq_comm, mul_add, ←
    mul_assoc, two_sinh, mul_left_comm, two_sinh, ← mul_right_inj' (two_ne_zero' ℂ), mul_add,
    mul_left_comm, two_cosh, ← mul_assoc, two_cosh]
  exact sinh_add_aux

@[simp]
theorem cosh_zero : cosh 0 = 1 := by simp [cosh]

@[simp]
theorem cosh_neg : cosh (-x) = cosh x := by simp [add_comm, cosh, exp_neg]

private theorem cosh_add_aux {a b c d : ℂ} :
    (a + b) * (c + d) + (a - b) * (c - d) = 2 * (a * c + b * d) := by ring

theorem cosh_add : cosh (x + y) = cosh x * cosh y + sinh x * sinh y := by
  rw [← mul_right_inj' (two_ne_zero' ℂ), two_cosh, exp_add, neg_add, exp_add, eq_comm, mul_add, ←
    mul_assoc, two_cosh, ← mul_assoc, two_sinh, ← mul_right_inj' (two_ne_zero' ℂ), mul_add,
    mul_left_comm, two_cosh, mul_left_comm, two_sinh]
  exact cosh_add_aux

theorem sinh_sub : sinh (x - y) = sinh x * cosh y - cosh x * sinh y := by
  simp [sub_eq_add_neg, sinh_add, sinh_neg, cosh_neg]

theorem cosh_sub : cosh (x - y) = cosh x * cosh y - sinh x * sinh y := by
  simp [sub_eq_add_neg, cosh_add, sinh_neg, cosh_neg]

theorem sinh_conj : sinh (conj x) = conj (sinh x) := by
  rw [sinh, ← RingHom.map_neg, exp_conj, exp_conj, ← RingHom.map_sub, sinh, map_div₀]
  -- Porting note: not nice
  simp [← one_add_one_eq_two]

@[simp]
theorem ofReal_sinh_ofReal_re (x : ℝ) : ((sinh x).re : ℂ) = sinh x :=
  conj_eq_iff_re.1 <| by rw [← sinh_conj, conj_ofReal]

@[simp, norm_cast]
theorem ofReal_sinh (x : ℝ) : (Real.sinh x : ℂ) = sinh x :=
  ofReal_sinh_ofReal_re _

@[simp]
theorem sinh_ofReal_im (x : ℝ) : (sinh x).im = 0 := by rw [← ofReal_sinh_ofReal_re, ofReal_im]

theorem sinh_ofReal_re (x : ℝ) : (sinh x).re = Real.sinh x :=
  rfl

theorem cosh_conj : cosh (conj x) = conj (cosh x) := by
  rw [cosh, ← RingHom.map_neg, exp_conj, exp_conj, ← RingHom.map_add, cosh, map_div₀]
  -- Porting note: not nice
  simp [← one_add_one_eq_two]

theorem ofReal_cosh_ofReal_re (x : ℝ) : ((cosh x).re : ℂ) = cosh x :=
  conj_eq_iff_re.1 <| by rw [← cosh_conj, conj_ofReal]

@[simp, norm_cast]
theorem ofReal_cosh (x : ℝ) : (Real.cosh x : ℂ) = cosh x :=
  ofReal_cosh_ofReal_re _

@[simp]
theorem cosh_ofReal_im (x : ℝ) : (cosh x).im = 0 := by rw [← ofReal_cosh_ofReal_re, ofReal_im]

@[simp]
theorem cosh_ofReal_re (x : ℝ) : (cosh x).re = Real.cosh x :=
  rfl

theorem tanh_eq_sinh_div_cosh : tanh x = sinh x / cosh x :=
  rfl

@[simp]
theorem tanh_zero : tanh 0 = 0 := by simp [tanh]

@[simp]
theorem tanh_neg : tanh (-x) = -tanh x := by simp [tanh, neg_div]

theorem tanh_conj : tanh (conj x) = conj (tanh x) := by
  rw [tanh, sinh_conj, cosh_conj, ← map_div₀, tanh]

@[simp]
theorem ofReal_tanh_ofReal_re (x : ℝ) : ((tanh x).re : ℂ) = tanh x :=
  conj_eq_iff_re.1 <| by rw [← tanh_conj, conj_ofReal]

@[simp, norm_cast]
theorem ofReal_tanh (x : ℝ) : (Real.tanh x : ℂ) = tanh x :=
  ofReal_tanh_ofReal_re _

@[simp]
theorem tanh_ofReal_im (x : ℝ) : (tanh x).im = 0 := by rw [← ofReal_tanh_ofReal_re, ofReal_im]

theorem tanh_ofReal_re (x : ℝ) : (tanh x).re = Real.tanh x :=
  rfl

@[simp]
theorem cosh_add_sinh : cosh x + sinh x = exp x := by
  rw [← mul_right_inj' (two_ne_zero' ℂ), mul_add, two_cosh, two_sinh, add_add_sub_cancel, two_mul]

@[simp]
theorem sinh_add_cosh : sinh x + cosh x = exp x := by rw [add_comm, cosh_add_sinh]

@[simp]
theorem exp_sub_cosh : exp x - cosh x = sinh x :=
  sub_eq_iff_eq_add.2 (sinh_add_cosh x).symm

@[simp]
theorem exp_sub_sinh : exp x - sinh x = cosh x :=
  sub_eq_iff_eq_add.2 (cosh_add_sinh x).symm

@[simp]
theorem cosh_sub_sinh : cosh x - sinh x = exp (-x) := by
  rw [← mul_right_inj' (two_ne_zero' ℂ), mul_sub, two_cosh, two_sinh, add_sub_sub_cancel, two_mul]

@[simp]
theorem sinh_sub_cosh : sinh x - cosh x = -exp (-x) := by rw [← neg_sub, cosh_sub_sinh]

@[simp]
theorem cosh_sq_sub_sinh_sq : cosh x ^ 2 - sinh x ^ 2 = 1 := by
  rw [sq_sub_sq, cosh_add_sinh, cosh_sub_sinh, ← exp_add, add_neg_cancel, exp_zero]

theorem cosh_sq : cosh x ^ 2 = sinh x ^ 2 + 1 := by
  rw [← cosh_sq_sub_sinh_sq x]
  ring

theorem sinh_sq : sinh x ^ 2 = cosh x ^ 2 - 1 := by
  rw [← cosh_sq_sub_sinh_sq x]
  ring

theorem cosh_two_mul : cosh (2 * x) = cosh x ^ 2 + sinh x ^ 2 := by rw [two_mul, cosh_add, sq, sq]

theorem sinh_two_mul : sinh (2 * x) = 2 * sinh x * cosh x := by
  rw [two_mul, sinh_add]
  ring

theorem cosh_three_mul : cosh (3 * x) = 4 * cosh x ^ 3 - 3 * cosh x := by
  have h1 : x + 2 * x = 3 * x := by ring
  rw [← h1, cosh_add x (2 * x)]
  simp only [cosh_two_mul, sinh_two_mul]
  have h2 : sinh x * (2 * sinh x * cosh x) = 2 * cosh x * sinh x ^ 2 := by ring
  rw [h2, sinh_sq]
  ring

theorem sinh_three_mul : sinh (3 * x) = 4 * sinh x ^ 3 + 3 * sinh x := by
  have h1 : x + 2 * x = 3 * x := by ring
  rw [← h1, sinh_add x (2 * x)]
  simp only [cosh_two_mul, sinh_two_mul]
  have h2 : cosh x * (2 * sinh x * cosh x) = 2 * sinh x * cosh x ^ 2 := by ring
  rw [h2, cosh_sq]
  ring

@[simp]
theorem sin_zero : sin 0 = 0 := by simp [sin]

@[simp]
theorem sin_neg : sin (-x) = -sin x := by
  simp [sin, sub_eq_add_neg, exp_neg, (neg_div _ _).symm, add_mul]

theorem two_sin : 2 * sin x = (exp (-x * I) - exp (x * I)) * I :=
  mul_div_cancel₀ _ two_ne_zero

theorem two_cos : 2 * cos x = exp (x * I) + exp (-x * I) :=
  mul_div_cancel₀ _ two_ne_zero

theorem sinh_mul_I : sinh (x * I) = sin x * I := by
  rw [← mul_right_inj' (two_ne_zero' ℂ), two_sinh, ← mul_assoc, two_sin, mul_assoc, I_mul_I,
    mul_neg_one, neg_sub, neg_mul_eq_neg_mul]

theorem cosh_mul_I : cosh (x * I) = cos x := by
  rw [← mul_right_inj' (two_ne_zero' ℂ), two_cosh, two_cos, neg_mul_eq_neg_mul]

theorem tanh_mul_I : tanh (x * I) = tan x * I := by
  rw [tanh_eq_sinh_div_cosh, cosh_mul_I, sinh_mul_I, mul_div_right_comm, tan]

theorem cos_mul_I : cos (x * I) = cosh x := by rw [← cosh_mul_I]; ring_nf; simp

theorem sin_mul_I : sin (x * I) = sinh x * I := by
  have h : I * sin (x * I) = -sinh x := by
    rw [mul_comm, ← sinh_mul_I]
    ring_nf
    simp
  rw [← neg_neg (sinh x), ← h]
  apply Complex.ext <;> simp

theorem tan_mul_I : tan (x * I) = tanh x * I := by
  rw [tan, sin_mul_I, cos_mul_I, mul_div_right_comm, tanh_eq_sinh_div_cosh]

theorem sin_add : sin (x + y) = sin x * cos y + cos x * sin y := by
  rw [← mul_left_inj' I_ne_zero, ← sinh_mul_I, add_mul, add_mul, mul_right_comm, ← sinh_mul_I,
    mul_assoc, ← sinh_mul_I, ← cosh_mul_I, ← cosh_mul_I, sinh_add]

@[simp]
theorem cos_zero : cos 0 = 1 := by simp [cos]

@[simp]
theorem cos_neg : cos (-x) = cos x := by simp [cos, sub_eq_add_neg, exp_neg, add_comm]

private theorem cos_add_aux {a b c d : ℂ} :
    (a + b) * (c + d) - (b - a) * (d - c) * -1 = 2 * (a * c + b * d) := by ring

theorem cos_add : cos (x + y) = cos x * cos y - sin x * sin y := by
  rw [← cosh_mul_I, add_mul, cosh_add, cosh_mul_I, cosh_mul_I, sinh_mul_I, sinh_mul_I,
    mul_mul_mul_comm, I_mul_I, mul_neg_one, sub_eq_add_neg]

theorem sin_sub : sin (x - y) = sin x * cos y - cos x * sin y := by
  simp [sub_eq_add_neg, sin_add, sin_neg, cos_neg]

theorem cos_sub : cos (x - y) = cos x * cos y + sin x * sin y := by
  simp [sub_eq_add_neg, cos_add, sin_neg, cos_neg]

theorem sin_add_mul_I (x y : ℂ) : sin (x + y * I) = sin x * cosh y + cos x * sinh y * I := by
  rw [sin_add, cos_mul_I, sin_mul_I, mul_assoc]

theorem sin_eq (z : ℂ) : sin z = sin z.re * cosh z.im + cos z.re * sinh z.im * I := by
  convert sin_add_mul_I z.re z.im; exact (re_add_im z).symm

theorem cos_add_mul_I (x y : ℂ) : cos (x + y * I) = cos x * cosh y - sin x * sinh y * I := by
  rw [cos_add, cos_mul_I, sin_mul_I, mul_assoc]

theorem cos_eq (z : ℂ) : cos z = cos z.re * cosh z.im - sin z.re * sinh z.im * I := by
  convert cos_add_mul_I z.re z.im; exact (re_add_im z).symm

theorem sin_sub_sin : sin x - sin y = 2 * sin ((x - y) / 2) * cos ((x + y) / 2) := by
  have s1 := sin_add ((x + y) / 2) ((x - y) / 2)
  have s2 := sin_sub ((x + y) / 2) ((x - y) / 2)
  rw [div_add_div_same, add_sub, add_right_comm, add_sub_cancel_right, add_self_div_two] at s1
  rw [div_sub_div_same, ← sub_add, add_sub_cancel_left, add_self_div_two] at s2
  rw [s1, s2]
  ring

theorem cos_sub_cos : cos x - cos y = -2 * sin ((x + y) / 2) * sin ((x - y) / 2) := by
  have s1 := cos_add ((x + y) / 2) ((x - y) / 2)
  have s2 := cos_sub ((x + y) / 2) ((x - y) / 2)
  rw [div_add_div_same, add_sub, add_right_comm, add_sub_cancel_right, add_self_div_two] at s1
  rw [div_sub_div_same, ← sub_add, add_sub_cancel_left, add_self_div_two] at s2
  rw [s1, s2]
  ring

theorem sin_add_sin : sin x + sin y = 2 * sin ((x + y) / 2) * cos ((x - y) / 2) := by
  simpa using sin_sub_sin x (-y)

theorem cos_add_cos : cos x + cos y = 2 * cos ((x + y) / 2) * cos ((x - y) / 2) := by
  calc
    cos x + cos y = cos ((x + y) / 2 + (x - y) / 2) + cos ((x + y) / 2 - (x - y) / 2) := ?_
    _ =
        cos ((x + y) / 2) * cos ((x - y) / 2) - sin ((x + y) / 2) * sin ((x - y) / 2) +
          (cos ((x + y) / 2) * cos ((x - y) / 2) + sin ((x + y) / 2) * sin ((x - y) / 2)) :=
      ?_
    _ = 2 * cos ((x + y) / 2) * cos ((x - y) / 2) := ?_

  · congr <;> field_simp
  · rw [cos_add, cos_sub]
  ring

theorem sin_conj : sin (conj x) = conj (sin x) := by
  rw [← mul_left_inj' I_ne_zero, ← sinh_mul_I, ← conj_neg_I, ← RingHom.map_mul, ← RingHom.map_mul,
    sinh_conj, mul_neg, sinh_neg, sinh_mul_I, mul_neg]

@[simp]
theorem ofReal_sin_ofReal_re (x : ℝ) : ((sin x).re : ℂ) = sin x :=
  conj_eq_iff_re.1 <| by rw [← sin_conj, conj_ofReal]

@[simp, norm_cast]
theorem ofReal_sin (x : ℝ) : (Real.sin x : ℂ) = sin x :=
  ofReal_sin_ofReal_re _

@[simp]
theorem sin_ofReal_im (x : ℝ) : (sin x).im = 0 := by rw [← ofReal_sin_ofReal_re, ofReal_im]

theorem sin_ofReal_re (x : ℝ) : (sin x).re = Real.sin x :=
  rfl

theorem cos_conj : cos (conj x) = conj (cos x) := by
  rw [← cosh_mul_I, ← conj_neg_I, ← RingHom.map_mul, ← cosh_mul_I, cosh_conj, mul_neg, cosh_neg]

@[simp]
theorem ofReal_cos_ofReal_re (x : ℝ) : ((cos x).re : ℂ) = cos x :=
  conj_eq_iff_re.1 <| by rw [← cos_conj, conj_ofReal]

@[simp, norm_cast]
theorem ofReal_cos (x : ℝ) : (Real.cos x : ℂ) = cos x :=
  ofReal_cos_ofReal_re _

@[simp]
theorem cos_ofReal_im (x : ℝ) : (cos x).im = 0 := by rw [← ofReal_cos_ofReal_re, ofReal_im]

theorem cos_ofReal_re (x : ℝ) : (cos x).re = Real.cos x :=
  rfl

@[simp]
theorem tan_zero : tan 0 = 0 := by simp [tan]

theorem tan_eq_sin_div_cos : tan x = sin x / cos x :=
  rfl

theorem cot_eq_cos_div_sin : cot x = cos x / sin x :=
  rfl

theorem tan_mul_cos {x : ℂ} (hx : cos x ≠ 0) : tan x * cos x = sin x := by
  rw [tan_eq_sin_div_cos, div_mul_cancel₀ _ hx]

@[simp]
theorem tan_neg : tan (-x) = -tan x := by simp [tan, neg_div]

theorem tan_conj : tan (conj x) = conj (tan x) := by rw [tan, sin_conj, cos_conj, ← map_div₀, tan]

theorem cot_conj : cot (conj x) = conj (cot x) := by rw [cot, sin_conj, cos_conj, ← map_div₀, cot]

@[simp]
theorem ofReal_tan_ofReal_re (x : ℝ) : ((tan x).re : ℂ) = tan x :=
  conj_eq_iff_re.1 <| by rw [← tan_conj, conj_ofReal]

@[simp]
theorem ofReal_cot_ofReal_re (x : ℝ) : ((cot x).re : ℂ) = cot x :=
  conj_eq_iff_re.1 <| by rw [← cot_conj, conj_ofReal]

@[simp, norm_cast]
theorem ofReal_tan (x : ℝ) : (Real.tan x : ℂ) = tan x :=
  ofReal_tan_ofReal_re _

@[simp, norm_cast]
theorem ofReal_cot (x : ℝ) : (Real.cot x : ℂ) = cot x :=
  ofReal_cot_ofReal_re _

@[simp]
theorem tan_ofReal_im (x : ℝ) : (tan x).im = 0 := by rw [← ofReal_tan_ofReal_re, ofReal_im]

theorem tan_ofReal_re (x : ℝ) : (tan x).re = Real.tan x :=
  rfl

theorem cos_add_sin_I : cos x + sin x * I = exp (x * I) := by
  rw [← cosh_add_sinh, sinh_mul_I, cosh_mul_I]

theorem cos_sub_sin_I : cos x - sin x * I = exp (-x * I) := by
  rw [neg_mul, ← cosh_sub_sinh, sinh_mul_I, cosh_mul_I]

@[simp]
theorem sin_sq_add_cos_sq : sin x ^ 2 + cos x ^ 2 = 1 :=
  Eq.trans (by rw [cosh_mul_I, sinh_mul_I, mul_pow, I_sq, mul_neg_one, sub_neg_eq_add, add_comm])
    (cosh_sq_sub_sinh_sq (x * I))

@[simp]
theorem cos_sq_add_sin_sq : cos x ^ 2 + sin x ^ 2 = 1 := by rw [add_comm, sin_sq_add_cos_sq]

theorem cos_two_mul' : cos (2 * x) = cos x ^ 2 - sin x ^ 2 := by rw [two_mul, cos_add, ← sq, ← sq]

theorem cos_two_mul : cos (2 * x) = 2 * cos x ^ 2 - 1 := by
  rw [cos_two_mul', eq_sub_iff_add_eq.2 (sin_sq_add_cos_sq x), ← sub_add, sub_add_eq_add_sub,
    two_mul]

theorem sin_two_mul : sin (2 * x) = 2 * sin x * cos x := by
  rw [two_mul, sin_add, two_mul, add_mul, mul_comm]

theorem cos_sq : cos x ^ 2 = 1 / 2 + cos (2 * x) / 2 := by
  simp [cos_two_mul, div_add_div_same, mul_div_cancel_left₀, two_ne_zero, -one_div]

theorem cos_sq' : cos x ^ 2 = 1 - sin x ^ 2 := by rw [← sin_sq_add_cos_sq x, add_sub_cancel_left]

theorem sin_sq : sin x ^ 2 = 1 - cos x ^ 2 := by rw [← sin_sq_add_cos_sq x, add_sub_cancel_right]

theorem inv_one_add_tan_sq {x : ℂ} (hx : cos x ≠ 0) : (1 + tan x ^ 2)⁻¹ = cos x ^ 2 := by
  rw [tan_eq_sin_div_cos, div_pow]
  field_simp

theorem tan_sq_div_one_add_tan_sq {x : ℂ} (hx : cos x ≠ 0) :
    tan x ^ 2 / (1 + tan x ^ 2) = sin x ^ 2 := by
  simp only [← tan_mul_cos hx, mul_pow, ← inv_one_add_tan_sq hx, div_eq_mul_inv, one_mul]

theorem cos_three_mul : cos (3 * x) = 4 * cos x ^ 3 - 3 * cos x := by
  have h1 : x + 2 * x = 3 * x := by ring
  rw [← h1, cos_add x (2 * x)]
  simp only [cos_two_mul, sin_two_mul, mul_add, mul_sub, mul_one, sq]
  have h2 : 4 * cos x ^ 3 = 2 * cos x * cos x * cos x + 2 * cos x * cos x ^ 2 := by ring
  rw [h2, cos_sq']
  ring

theorem sin_three_mul : sin (3 * x) = 3 * sin x - 4 * sin x ^ 3 := by
  have h1 : x + 2 * x = 3 * x := by ring
  rw [← h1, sin_add x (2 * x)]
  simp only [cos_two_mul, sin_two_mul, cos_sq']
  have h2 : cos x * (2 * sin x * cos x) = 2 * sin x * cos x ^ 2 := by ring
  rw [h2, cos_sq']
  ring

theorem exp_mul_I : exp (x * I) = cos x + sin x * I :=
  (cos_add_sin_I _).symm

theorem exp_add_mul_I : exp (x + y * I) = exp x * (cos y + sin y * I) := by rw [exp_add, exp_mul_I]

theorem exp_eq_exp_re_mul_sin_add_cos : exp x = exp x.re * (cos x.im + sin x.im * I) := by
  rw [← exp_add_mul_I, re_add_im]

theorem exp_re : (exp x).re = Real.exp x.re * Real.cos x.im := by
  rw [exp_eq_exp_re_mul_sin_add_cos]
  simp [exp_ofReal_re, cos_ofReal_re]

theorem exp_im : (exp x).im = Real.exp x.re * Real.sin x.im := by
  rw [exp_eq_exp_re_mul_sin_add_cos]
  simp [exp_ofReal_re, sin_ofReal_re]

@[simp]
theorem exp_ofReal_mul_I_re (x : ℝ) : (exp (x * I)).re = Real.cos x := by
  simp [exp_mul_I, cos_ofReal_re]

@[simp]
theorem exp_ofReal_mul_I_im (x : ℝ) : (exp (x * I)).im = Real.sin x := by
  simp [exp_mul_I, sin_ofReal_re]

/-- **De Moivre's formula** -/
theorem cos_add_sin_mul_I_pow (n : ℕ) (z : ℂ) :
    (cos z + sin z * I) ^ n = cos (↑n * z) + sin (↑n * z) * I := by
  rw [← exp_mul_I, ← exp_mul_I]
  induction' n with n ih
  · rw [pow_zero, Nat.cast_zero, zero_mul, zero_mul, exp_zero]
  · rw [pow_succ, ih, Nat.cast_succ, add_mul, add_mul, one_mul, exp_add]

end Complex

namespace Real

open Complex

variable (x y : ℝ)

@[simp]
theorem exp_zero : exp 0 = 1 := by simp [Real.exp]

nonrec theorem exp_add : exp (x + y) = exp x * exp y := by simp [exp_add, exp]

-- Porting note (#11445): new definition
/-- the exponential function as a monoid hom from `Multiplicative ℝ` to `ℝ` -/
@[simps]
noncomputable def expMonoidHom : MonoidHom (Multiplicative ℝ) ℝ :=
  { toFun := fun x => exp (Multiplicative.toAdd x),
    map_one' := by simp,
    map_mul' := by simp [exp_add] }

theorem exp_list_sum (l : List ℝ) : exp l.sum = (l.map exp).prod :=
  map_list_prod (M := Multiplicative ℝ) expMonoidHom l

theorem exp_multiset_sum (s : Multiset ℝ) : exp s.sum = (s.map exp).prod :=
  @MonoidHom.map_multiset_prod (Multiplicative ℝ) ℝ _ _ expMonoidHom s

theorem exp_sum {α : Type*} (s : Finset α) (f : α → ℝ) :
    exp (∑ x ∈ s, f x) = ∏ x ∈ s, exp (f x) :=
  map_prod (β := Multiplicative ℝ) expMonoidHom f s

lemma exp_nsmul (x : ℝ) (n : ℕ) : exp (n • x) = exp x ^ n :=
  @MonoidHom.map_pow (Multiplicative ℝ) ℝ _ _  expMonoidHom _ _

nonrec theorem exp_nat_mul (x : ℝ) (n : ℕ) : exp (n * x) = exp x ^ n :=
  ofReal_injective (by simp [exp_nat_mul])

@[simp]
nonrec theorem exp_ne_zero : exp x ≠ 0 := fun h =>
  exp_ne_zero x <| by rw [exp, ← ofReal_inj] at h; simp_all

nonrec theorem exp_neg : exp (-x) = (exp x)⁻¹ :=
  ofReal_injective <| by simp [exp_neg]

theorem exp_sub : exp (x - y) = exp x / exp y := by
  simp [sub_eq_add_neg, exp_add, exp_neg, div_eq_mul_inv]

@[simp]
theorem sin_zero : sin 0 = 0 := by simp [sin]

@[simp]
theorem sin_neg : sin (-x) = -sin x := by simp [sin, exp_neg, (neg_div _ _).symm, add_mul]

nonrec theorem sin_add : sin (x + y) = sin x * cos y + cos x * sin y :=
  ofReal_injective <| by simp [sin_add]

@[simp]
theorem cos_zero : cos 0 = 1 := by simp [cos]

@[simp]
theorem cos_neg : cos (-x) = cos x := by simp [cos, exp_neg]

@[simp]
theorem cos_abs : cos |x| = cos x := by
  cases le_total x 0 <;> simp only [*, _root_.abs_of_nonneg, abs_of_nonpos, cos_neg]

nonrec theorem cos_add : cos (x + y) = cos x * cos y - sin x * sin y :=
  ofReal_injective <| by simp [cos_add]

theorem sin_sub : sin (x - y) = sin x * cos y - cos x * sin y := by
  simp [sub_eq_add_neg, sin_add, sin_neg, cos_neg]

theorem cos_sub : cos (x - y) = cos x * cos y + sin x * sin y := by
  simp [sub_eq_add_neg, cos_add, sin_neg, cos_neg]

nonrec theorem sin_sub_sin : sin x - sin y = 2 * sin ((x - y) / 2) * cos ((x + y) / 2) :=
  ofReal_injective <| by simp [sin_sub_sin]

nonrec theorem cos_sub_cos : cos x - cos y = -2 * sin ((x + y) / 2) * sin ((x - y) / 2) :=
  ofReal_injective <| by simp [cos_sub_cos]

nonrec theorem cos_add_cos : cos x + cos y = 2 * cos ((x + y) / 2) * cos ((x - y) / 2) :=
  ofReal_injective <| by simp [cos_add_cos]

nonrec theorem tan_eq_sin_div_cos : tan x = sin x / cos x :=
  ofReal_injective <| by simp only [ofReal_tan, tan_eq_sin_div_cos, ofReal_div, ofReal_sin,
    ofReal_cos]

nonrec theorem cot_eq_cos_div_sin : cot x = cos x / sin x :=
  ofReal_injective <| by simp [cot_eq_cos_div_sin]

theorem tan_mul_cos {x : ℝ} (hx : cos x ≠ 0) : tan x * cos x = sin x := by
  rw [tan_eq_sin_div_cos, div_mul_cancel₀ _ hx]

@[simp]
theorem tan_zero : tan 0 = 0 := by simp [tan]

@[simp]
theorem tan_neg : tan (-x) = -tan x := by simp [tan, neg_div]

@[simp]
nonrec theorem sin_sq_add_cos_sq : sin x ^ 2 + cos x ^ 2 = 1 :=
  ofReal_injective (by simp [sin_sq_add_cos_sq])

@[simp]
theorem cos_sq_add_sin_sq : cos x ^ 2 + sin x ^ 2 = 1 := by rw [add_comm, sin_sq_add_cos_sq]

theorem sin_sq_le_one : sin x ^ 2 ≤ 1 := by
  rw [← sin_sq_add_cos_sq x]; exact le_add_of_nonneg_right (sq_nonneg _)

theorem cos_sq_le_one : cos x ^ 2 ≤ 1 := by
  rw [← sin_sq_add_cos_sq x]; exact le_add_of_nonneg_left (sq_nonneg _)

theorem abs_sin_le_one : |sin x| ≤ 1 :=
  abs_le_one_iff_mul_self_le_one.2 <| by simp only [← sq, sin_sq_le_one]

theorem abs_cos_le_one : |cos x| ≤ 1 :=
  abs_le_one_iff_mul_self_le_one.2 <| by simp only [← sq, cos_sq_le_one]

theorem sin_le_one : sin x ≤ 1 :=
  (abs_le.1 (abs_sin_le_one _)).2

theorem cos_le_one : cos x ≤ 1 :=
  (abs_le.1 (abs_cos_le_one _)).2

theorem neg_one_le_sin : -1 ≤ sin x :=
  (abs_le.1 (abs_sin_le_one _)).1

theorem neg_one_le_cos : -1 ≤ cos x :=
  (abs_le.1 (abs_cos_le_one _)).1

nonrec theorem cos_two_mul : cos (2 * x) = 2 * cos x ^ 2 - 1 :=
  ofReal_injective <| by simp [cos_two_mul]

nonrec theorem cos_two_mul' : cos (2 * x) = cos x ^ 2 - sin x ^ 2 :=
  ofReal_injective <| by simp [cos_two_mul']

nonrec theorem sin_two_mul : sin (2 * x) = 2 * sin x * cos x :=
  ofReal_injective <| by simp [sin_two_mul]

nonrec theorem cos_sq : cos x ^ 2 = 1 / 2 + cos (2 * x) / 2 :=
  ofReal_injective <| by simp [cos_sq]

theorem cos_sq' : cos x ^ 2 = 1 - sin x ^ 2 := by rw [← sin_sq_add_cos_sq x, add_sub_cancel_left]

theorem sin_sq : sin x ^ 2 = 1 - cos x ^ 2 :=
  eq_sub_iff_add_eq.2 <| sin_sq_add_cos_sq _

lemma sin_sq_eq_half_sub : sin x ^ 2 = 1 / 2 - cos (2 * x) / 2 := by
  rw [sin_sq, cos_sq, ← sub_sub, sub_half]

theorem abs_sin_eq_sqrt_one_sub_cos_sq (x : ℝ) : |sin x| = √(1 - cos x ^ 2) := by
  rw [← sin_sq, sqrt_sq_eq_abs]

theorem abs_cos_eq_sqrt_one_sub_sin_sq (x : ℝ) : |cos x| = √(1 - sin x ^ 2) := by
  rw [← cos_sq', sqrt_sq_eq_abs]

theorem inv_one_add_tan_sq {x : ℝ} (hx : cos x ≠ 0) : (1 + tan x ^ 2)⁻¹ = cos x ^ 2 :=
  have : Complex.cos x ≠ 0 := mt (congr_arg re) hx
  ofReal_inj.1 <| by simpa using Complex.inv_one_add_tan_sq this

theorem tan_sq_div_one_add_tan_sq {x : ℝ} (hx : cos x ≠ 0) :
    tan x ^ 2 / (1 + tan x ^ 2) = sin x ^ 2 := by
  simp only [← tan_mul_cos hx, mul_pow, ← inv_one_add_tan_sq hx, div_eq_mul_inv, one_mul]

theorem inv_sqrt_one_add_tan_sq {x : ℝ} (hx : 0 < cos x) : (√(1 + tan x ^ 2))⁻¹ = cos x := by
  rw [← sqrt_sq hx.le, ← sqrt_inv, inv_one_add_tan_sq hx.ne']

theorem tan_div_sqrt_one_add_tan_sq {x : ℝ} (hx : 0 < cos x) :
    tan x / √(1 + tan x ^ 2) = sin x := by
  rw [← tan_mul_cos hx.ne', ← inv_sqrt_one_add_tan_sq hx, div_eq_mul_inv]

nonrec theorem cos_three_mul : cos (3 * x) = 4 * cos x ^ 3 - 3 * cos x := by
  rw [← ofReal_inj]; simp [cos_three_mul]

nonrec theorem sin_three_mul : sin (3 * x) = 3 * sin x - 4 * sin x ^ 3 := by
  rw [← ofReal_inj]; simp [sin_three_mul]

/-- The definition of `sinh` in terms of `exp`. -/
nonrec theorem sinh_eq (x : ℝ) : sinh x = (exp x - exp (-x)) / 2 :=
  ofReal_injective <| by simp [Complex.sinh]

@[simp]
theorem sinh_zero : sinh 0 = 0 := by simp [sinh]

@[simp]
theorem sinh_neg : sinh (-x) = -sinh x := by simp [sinh, exp_neg, (neg_div _ _).symm, add_mul]

nonrec theorem sinh_add : sinh (x + y) = sinh x * cosh y + cosh x * sinh y := by
  rw [← ofReal_inj]; simp [sinh_add]

/-- The definition of `cosh` in terms of `exp`. -/
theorem cosh_eq (x : ℝ) : cosh x = (exp x + exp (-x)) / 2 :=
  eq_div_of_mul_eq two_ne_zero <| by
    rw [cosh, exp, exp, Complex.ofReal_neg, Complex.cosh, mul_two, ← Complex.add_re, ← mul_two,
      div_mul_cancel₀ _ (two_ne_zero' ℂ), Complex.add_re]

@[simp]
theorem cosh_zero : cosh 0 = 1 := by simp [cosh]

@[simp]
theorem cosh_neg : cosh (-x) = cosh x :=
  ofReal_inj.1 <| by simp

@[simp]
theorem cosh_abs : cosh |x| = cosh x := by
  cases le_total x 0 <;> simp [*, _root_.abs_of_nonneg, abs_of_nonpos]

nonrec theorem cosh_add : cosh (x + y) = cosh x * cosh y + sinh x * sinh y := by
  rw [← ofReal_inj]; simp [cosh_add]

theorem sinh_sub : sinh (x - y) = sinh x * cosh y - cosh x * sinh y := by
  simp [sub_eq_add_neg, sinh_add, sinh_neg, cosh_neg]

theorem cosh_sub : cosh (x - y) = cosh x * cosh y - sinh x * sinh y := by
  simp [sub_eq_add_neg, cosh_add, sinh_neg, cosh_neg]

nonrec theorem tanh_eq_sinh_div_cosh : tanh x = sinh x / cosh x :=
  ofReal_inj.1 <| by simp [tanh_eq_sinh_div_cosh]

@[simp]
theorem tanh_zero : tanh 0 = 0 := by simp [tanh]

@[simp]
theorem tanh_neg : tanh (-x) = -tanh x := by simp [tanh, neg_div]

@[simp]
theorem cosh_add_sinh : cosh x + sinh x = exp x := by rw [← ofReal_inj]; simp

@[simp]
theorem sinh_add_cosh : sinh x + cosh x = exp x := by rw [add_comm, cosh_add_sinh]

@[simp]
theorem exp_sub_cosh : exp x - cosh x = sinh x :=
  sub_eq_iff_eq_add.2 (sinh_add_cosh x).symm

@[simp]
theorem exp_sub_sinh : exp x - sinh x = cosh x :=
  sub_eq_iff_eq_add.2 (cosh_add_sinh x).symm

@[simp]
theorem cosh_sub_sinh : cosh x - sinh x = exp (-x) := by
  rw [← ofReal_inj]
  simp

@[simp]
theorem sinh_sub_cosh : sinh x - cosh x = -exp (-x) := by rw [← neg_sub, cosh_sub_sinh]

@[simp]
theorem cosh_sq_sub_sinh_sq (x : ℝ) : cosh x ^ 2 - sinh x ^ 2 = 1 := by rw [← ofReal_inj]; simp

nonrec theorem cosh_sq : cosh x ^ 2 = sinh x ^ 2 + 1 := by rw [← ofReal_inj]; simp [cosh_sq]

theorem cosh_sq' : cosh x ^ 2 = 1 + sinh x ^ 2 :=
  (cosh_sq x).trans (add_comm _ _)

nonrec theorem sinh_sq : sinh x ^ 2 = cosh x ^ 2 - 1 := by rw [← ofReal_inj]; simp [sinh_sq]

nonrec theorem cosh_two_mul : cosh (2 * x) = cosh x ^ 2 + sinh x ^ 2 := by
  rw [← ofReal_inj]; simp [cosh_two_mul]

nonrec theorem sinh_two_mul : sinh (2 * x) = 2 * sinh x * cosh x := by
  rw [← ofReal_inj]; simp [sinh_two_mul]

nonrec theorem cosh_three_mul : cosh (3 * x) = 4 * cosh x ^ 3 - 3 * cosh x := by
  rw [← ofReal_inj]; simp [cosh_three_mul]

nonrec theorem sinh_three_mul : sinh (3 * x) = 4 * sinh x ^ 3 + 3 * sinh x := by
  rw [← ofReal_inj]; simp [sinh_three_mul]

open IsAbsoluteValue Nat

theorem sum_le_exp_of_nonneg {x : ℝ} (hx : 0 ≤ x) (n : ℕ) : ∑ i ∈ range n, x ^ i / i ! ≤ exp x :=
  calc
    ∑ i ∈ range n, x ^ i / i ! ≤ lim (⟨_, isCauSeq_re (exp' x)⟩ : CauSeq ℝ abs) := by
      refine le_lim (CauSeq.le_of_exists ⟨n, fun j hj => ?_⟩)
      simp only [exp', const_apply, re_sum]
      norm_cast
      refine sum_le_sum_of_subset_of_nonneg (range_mono hj) fun _ _ _ ↦ ?_
      positivity
    _ = exp x := by rw [exp, Complex.exp, ← cauSeqRe, lim_re]

lemma pow_div_factorial_le_exp (hx : 0 ≤ x) (n : ℕ) : x ^ n / n ! ≤ exp x :=
  calc
    x ^ n / n ! ≤ ∑ k ∈ range (n + 1), x ^ k / k ! :=
        single_le_sum (f := fun k ↦ x ^ k / k !) (fun k _ ↦ by positivity) (self_mem_range_succ n)
    _ ≤ exp x := sum_le_exp_of_nonneg hx _

theorem quadratic_le_exp_of_nonneg {x : ℝ} (hx : 0 ≤ x) : 1 + x + x ^ 2 / 2 ≤ exp x :=
  calc
    1 + x + x ^ 2 / 2 = ∑ i ∈ range 3, x ^ i / i ! := by
        simp only [sum_range_succ, range_one, sum_singleton, _root_.pow_zero, factorial, cast_one,
          ne_eq, one_ne_zero, not_false_eq_true, div_self, pow_one, mul_one, div_one, Nat.mul_one,
          cast_succ, add_right_inj]
        ring_nf
    _ ≤ exp x := sum_le_exp_of_nonneg hx 3

private theorem add_one_lt_exp_of_pos {x : ℝ} (hx : 0 < x) : x + 1 < exp x :=
  (by nlinarith : x + 1 < 1 + x + x ^ 2 / 2).trans_le (quadratic_le_exp_of_nonneg hx.le)

private theorem add_one_le_exp_of_nonneg {x : ℝ} (hx : 0 ≤ x) : x + 1 ≤ exp x := by
  rcases eq_or_lt_of_le hx with (rfl | h)
  · simp
  exact (add_one_lt_exp_of_pos h).le

theorem one_le_exp {x : ℝ} (hx : 0 ≤ x) : 1 ≤ exp x := by linarith [add_one_le_exp_of_nonneg hx]

@[bound]
theorem exp_pos (x : ℝ) : 0 < exp x :=
  (le_total 0 x).elim (lt_of_lt_of_le zero_lt_one ∘ one_le_exp) fun h => by
    rw [← neg_neg x, Real.exp_neg]
    exact inv_pos.2 (lt_of_lt_of_le zero_lt_one (one_le_exp (neg_nonneg.2 h)))

@[bound]
lemma exp_nonneg (x : ℝ) : 0 ≤ exp x := x.exp_pos.le

@[simp]
theorem abs_exp (x : ℝ) : |exp x| = exp x :=
  abs_of_pos (exp_pos _)

lemma exp_abs_le (x : ℝ) : exp |x| ≤ exp x + exp (-x) := by
  cases le_total x 0 <;> simp [abs_of_nonpos, _root_.abs_of_nonneg, exp_nonneg, *]

@[mono]
theorem exp_strictMono : StrictMono exp := fun x y h => by
  rw [← sub_add_cancel y x, Real.exp_add]
  exact (lt_mul_iff_one_lt_left (exp_pos _)).2
      (lt_of_lt_of_le (by linarith) (add_one_le_exp_of_nonneg (by linarith)))

@[gcongr]
theorem exp_lt_exp_of_lt {x y : ℝ} (h : x < y) : exp x < exp y := exp_strictMono h

@[mono]
theorem exp_monotone : Monotone exp :=
  exp_strictMono.monotone

@[gcongr, bound]
theorem exp_le_exp_of_le {x y : ℝ} (h : x ≤ y) : exp x ≤ exp y := exp_monotone h

@[simp]
theorem exp_lt_exp {x y : ℝ} : exp x < exp y ↔ x < y :=
  exp_strictMono.lt_iff_lt

@[simp]
theorem exp_le_exp {x y : ℝ} : exp x ≤ exp y ↔ x ≤ y :=
  exp_strictMono.le_iff_le

theorem exp_injective : Function.Injective exp :=
  exp_strictMono.injective

@[simp]
theorem exp_eq_exp {x y : ℝ} : exp x = exp y ↔ x = y :=
  exp_injective.eq_iff

@[simp]
theorem exp_eq_one_iff : exp x = 1 ↔ x = 0 :=
  exp_injective.eq_iff' exp_zero

@[simp]
theorem one_lt_exp_iff {x : ℝ} : 1 < exp x ↔ 0 < x := by rw [← exp_zero, exp_lt_exp]

@[bound] private alias ⟨_, Bound.one_lt_exp_of_pos⟩ := one_lt_exp_iff

@[simp]
theorem exp_lt_one_iff {x : ℝ} : exp x < 1 ↔ x < 0 := by rw [← exp_zero, exp_lt_exp]

@[simp]
theorem exp_le_one_iff {x : ℝ} : exp x ≤ 1 ↔ x ≤ 0 :=
  exp_zero ▸ exp_le_exp

@[simp]
theorem one_le_exp_iff {x : ℝ} : 1 ≤ exp x ↔ 0 ≤ x :=
  exp_zero ▸ exp_le_exp

/-- `Real.cosh` is always positive -/
theorem cosh_pos (x : ℝ) : 0 < Real.cosh x :=
  (cosh_eq x).symm ▸ half_pos (add_pos (exp_pos x) (exp_pos (-x)))

theorem sinh_lt_cosh : sinh x < cosh x :=
  lt_of_pow_lt_pow_left 2 (cosh_pos _).le <| (cosh_sq x).symm ▸ lt_add_one _

end Real

namespace Complex

theorem sum_div_factorial_le {α : Type*} [LinearOrderedField α] (n j : ℕ) (hn : 0 < n) :
    (∑ m ∈ range j with n ≤ m, (1 / m.factorial : α)) ≤ n.succ / (n.factorial * n) :=
  calc
    (∑ m ∈ range j with n ≤ m, (1 / m.factorial : α)) =
        ∑ m ∈ range (j - n), (1 / ((m + n).factorial : α)) := by
        refine sum_nbij' (· - n) (· + n) ?_ ?_ ?_ ?_ ?_ <;>
          simp (config := { contextual := true }) [lt_tsub_iff_right, tsub_add_cancel_of_le]
    _ ≤ ∑ m ∈ range (j - n), ((n.factorial : α) * (n.succ : α) ^ m)⁻¹ := by
      simp_rw [one_div]
      gcongr
      rw [← Nat.cast_pow, ← Nat.cast_mul, Nat.cast_le, add_comm]
      exact Nat.factorial_mul_pow_le_factorial
    _ = (n.factorial : α)⁻¹ * ∑ m ∈ range (j - n), (n.succ : α)⁻¹ ^ m := by
      simp [mul_inv, ← mul_sum, ← sum_mul, mul_comm, inv_pow]
    _ = ((n.succ : α) - n.succ * (n.succ : α)⁻¹ ^ (j - n)) / (n.factorial * n) := by
      have h₁ : (n.succ : α) ≠ 1 :=
        @Nat.cast_one α _ ▸ mt Nat.cast_inj.1 (mt Nat.succ.inj (pos_iff_ne_zero.1 hn))
      have h₂ : (n.succ : α) ≠ 0 := by positivity
      have h₃ : (n.factorial * n : α) ≠ 0 := by positivity
      have h₄ : (n.succ - 1 : α) = n := by simp
      rw [geom_sum_inv h₁ h₂, eq_div_iff_mul_eq h₃, mul_comm _ (n.factorial * n : α),
          ← mul_assoc (n.factorial⁻¹ : α), ← mul_inv_rev, h₄, ← mul_assoc (n.factorial * n : α),
          mul_comm (n : α) n.factorial, mul_inv_cancel₀ h₃, one_mul, mul_comm]
    _ ≤ n.succ / (n.factorial * n : α) := by gcongr; apply sub_le_self; positivity

theorem exp_bound {x : ℂ} (hx : abs x ≤ 1) {n : ℕ} (hn : 0 < n) :
    abs (exp x - ∑ m ∈ range n, x ^ m / m.factorial) ≤
      abs x ^ n * ((n.succ : ℝ) * (n.factorial * n : ℝ)⁻¹) := by
  rw [← lim_const (abv := Complex.abs) (∑ m ∈ range n, _), exp, sub_eq_add_neg,
    ← lim_neg, lim_add, ← lim_abs]
  refine lim_le (CauSeq.le_of_exists ⟨n, fun j hj => ?_⟩)
  simp_rw [← sub_eq_add_neg]
  show
    abs ((∑ m ∈ range j, x ^ m / m.factorial) - ∑ m ∈ range n, x ^ m / m.factorial) ≤
      abs x ^ n * ((n.succ : ℝ) * (n.factorial * n : ℝ)⁻¹)
  rw [sum_range_sub_sum_range hj]
  calc
    abs (∑ m ∈ range j with n ≤ m, (x ^ m / m.factorial : ℂ))
      = abs (∑ m ∈ range j with n ≤ m, (x ^ n * (x ^ (m - n) / m.factorial) : ℂ)) := by
      refine congr_arg abs (sum_congr rfl fun m hm => ?_)
      rw [mem_filter, mem_range] at hm
      rw [← mul_div_assoc, ← pow_add, add_tsub_cancel_of_le hm.2]
    _ ≤ ∑ m ∈ range j with n ≤ m, abs (x ^ n * (x ^ (m - n) / m.factorial)) :=
      IsAbsoluteValue.abv_sum Complex.abs ..
    _ ≤ ∑ m ∈ range j with n ≤ m, abs x ^ n * (1 / m.factorial) := by
      simp_rw [map_mul, map_pow, map_div₀, abs_natCast]
      gcongr
      rw [abv_pow abs]
      exact pow_le_one₀ (abs.nonneg _) hx
    _ = abs x ^ n * ∑ m ∈ range j with n ≤ m, (1 / m.factorial : ℝ) := by
      simp [abs_mul, abv_pow abs, abs_div, ← mul_sum]
    _ ≤ abs x ^ n * (n.succ * (n.factorial * n : ℝ)⁻¹) := by
      gcongr
      exact sum_div_factorial_le _ _ hn

theorem exp_bound' {x : ℂ} {n : ℕ} (hx : abs x / n.succ ≤ 1 / 2) :
    abs (exp x - ∑ m ∈ range n, x ^ m / m.factorial) ≤ abs x ^ n / n.factorial * 2 := by
  rw [← lim_const (abv := Complex.abs) (∑ m ∈ range n, _),
    exp, sub_eq_add_neg, ← lim_neg, lim_add, ← lim_abs]
  refine lim_le (CauSeq.le_of_exists ⟨n, fun j hj => ?_⟩)
  simp_rw [← sub_eq_add_neg]
  show abs ((∑ m ∈ range j, x ^ m / m.factorial) - ∑ m ∈ range n, x ^ m / m.factorial) ≤
    abs x ^ n / n.factorial * 2
  let k := j - n
  have hj : j = n + k := (add_tsub_cancel_of_le hj).symm
  rw [hj, sum_range_add_sub_sum_range]
  calc
    abs (∑ i ∈ range k, x ^ (n + i) / ((n + i).factorial : ℂ)) ≤
        ∑ i ∈ range k, abs (x ^ (n + i) / ((n + i).factorial : ℂ)) :=
      IsAbsoluteValue.abv_sum _ _ _
    _ ≤ ∑ i ∈ range k, abs x ^ (n + i) / (n + i).factorial := by
      simp [Complex.abs_natCast, map_div₀, abv_pow abs]
    _ ≤ ∑ i ∈ range k, abs x ^ (n + i) / ((n.factorial : ℝ) * (n.succ : ℝ) ^ i) := ?_
    _ = ∑ i ∈ range k, abs x ^ n / n.factorial * (abs x ^ i / (n.succ : ℝ) ^ i) := ?_
    _ ≤ abs x ^ n / ↑n.factorial * 2 := ?_
  · gcongr
    exact mod_cast Nat.factorial_mul_pow_le_factorial
  · refine Finset.sum_congr rfl fun _ _ => ?_
    simp only [pow_add, div_eq_inv_mul, mul_inv, mul_left_comm, mul_assoc]
  · rw [← mul_sum]
    gcongr
    simp_rw [← div_pow]
    rw [geom_sum_eq, div_le_iff_of_neg]
    · trans (-1 : ℝ)
      · linarith
      · simp only [neg_le_sub_iff_le_add, div_pow, Nat.cast_succ, le_add_iff_nonneg_left]
        positivity
    · linarith
    · linarith

theorem abs_exp_sub_one_le {x : ℂ} (hx : abs x ≤ 1) : abs (exp x - 1) ≤ 2 * abs x :=
  calc
    abs (exp x - 1) = abs (exp x - ∑ m ∈ range 1, x ^ m / m.factorial) := by simp [sum_range_succ]
    _ ≤ abs x ^ 1 * ((Nat.succ 1 : ℝ) * ((Nat.factorial 1) * (1 : ℕ) : ℝ)⁻¹) :=
      (exp_bound hx (by decide))
    _ = 2 * abs x := by simp [two_mul, mul_two, mul_add, mul_comm, add_mul, Nat.factorial]

theorem abs_exp_sub_one_sub_id_le {x : ℂ} (hx : abs x ≤ 1) : abs (exp x - 1 - x) ≤ abs x ^ 2 :=
  calc
    abs (exp x - 1 - x) = abs (exp x - ∑ m ∈ range 2, x ^ m / m.factorial) := by
      simp [sub_eq_add_neg, sum_range_succ_comm, add_assoc, Nat.factorial]
    _ ≤ abs x ^ 2 * ((Nat.succ 2 : ℝ) * (Nat.factorial 2 * (2 : ℕ) : ℝ)⁻¹) :=
      (exp_bound hx (by decide))
    _ ≤ abs x ^ 2 * 1 := by gcongr; norm_num [Nat.factorial]
    _ = abs x ^ 2 := by rw [mul_one]

end Complex

namespace Real

open Complex Finset

nonrec theorem exp_bound {x : ℝ} (hx : |x| ≤ 1) {n : ℕ} (hn : 0 < n) :
    |exp x - ∑ m ∈ range n, x ^ m / m.factorial| ≤ |x| ^ n * (n.succ / (n.factorial * n)) := by
  have hxc : Complex.abs x ≤ 1 := mod_cast hx
  convert exp_bound hxc hn using 2 <;>
  -- Porting note: was `norm_cast`
  simp only [← abs_ofReal, ← ofReal_sub, ← ofReal_exp, ← ofReal_sum, ← ofReal_pow,
    ← ofReal_div, ← ofReal_natCast]

theorem exp_bound' {x : ℝ} (h1 : 0 ≤ x) (h2 : x ≤ 1) {n : ℕ} (hn : 0 < n) :
    Real.exp x ≤ (∑ m ∈ Finset.range n, x ^ m / m.factorial) +
      x ^ n * (n + 1) / (n.factorial * n) := by
  have h3 : |x| = x := by simpa
  have h4 : |x| ≤ 1 := by rwa [h3]
  have h' := Real.exp_bound h4 hn
  rw [h3] at h'
  have h'' := (abs_sub_le_iff.1 h').1
  have t := sub_le_iff_le_add'.1 h''
  simpa [mul_div_assoc] using t

theorem abs_exp_sub_one_le {x : ℝ} (hx : |x| ≤ 1) : |exp x - 1| ≤ 2 * |x| := by
  have : |x| ≤ 1 := mod_cast hx
  -- Porting note: was
  --exact_mod_cast Complex.abs_exp_sub_one_le (x := x) this
  have := Complex.abs_exp_sub_one_le (x := x) (by simpa using this)
  rw [← ofReal_exp, ← ofReal_one, ← ofReal_sub, abs_ofReal, abs_ofReal] at this
  exact this

theorem abs_exp_sub_one_sub_id_le {x : ℝ} (hx : |x| ≤ 1) : |exp x - 1 - x| ≤ x ^ 2 := by
  rw [← _root_.sq_abs]
  -- Porting note: was
  -- exact_mod_cast Complex.abs_exp_sub_one_sub_id_le this
  have : Complex.abs x ≤ 1 := mod_cast hx
  have := Complex.abs_exp_sub_one_sub_id_le this
  rw [← ofReal_one, ← ofReal_exp, ← ofReal_sub, ← ofReal_sub, abs_ofReal, abs_ofReal] at this
  exact this

/-- A finite initial segment of the exponential series, followed by an arbitrary tail.
For fixed `n` this is just a linear map wrt `r`, and each map is a simple linear function
of the previous (see `expNear_succ`), with `expNear n x r ⟶ exp x` as `n ⟶ ∞`,
for any `r`. -/
noncomputable def expNear (n : ℕ) (x r : ℝ) : ℝ :=
  (∑ m ∈ range n, x ^ m / m.factorial) + x ^ n / n.factorial * r

@[simp]
theorem expNear_zero (x r) : expNear 0 x r = r := by simp [expNear]

@[simp]
theorem expNear_succ (n x r) : expNear (n + 1) x r = expNear n x (1 + x / (n + 1) * r) := by
  simp [expNear, range_succ, mul_add, add_left_comm, add_assoc, pow_succ, div_eq_mul_inv,
      mul_inv, Nat.factorial]
  ac_rfl

theorem expNear_sub (n x r₁ r₂) : expNear n x r₁ -
    expNear n x r₂ = x ^ n / n.factorial * (r₁ - r₂) := by
  simp [expNear, mul_sub]

theorem exp_approx_end (n m : ℕ) (x : ℝ) (e₁ : n + 1 = m) (h : |x| ≤ 1) :
    |exp x - expNear m x 0| ≤ |x| ^ m / m.factorial * ((m + 1) / m) := by
  simp only [expNear, mul_zero, add_zero]
  convert exp_bound (n := m) h ?_ using 1
  · field_simp [mul_comm]
  · omega

theorem exp_approx_succ {n} {x a₁ b₁ : ℝ} (m : ℕ) (e₁ : n + 1 = m) (a₂ b₂ : ℝ)
    (e : |1 + x / m * a₂ - a₁| ≤ b₁ - |x| / m * b₂)
    (h : |exp x - expNear m x a₂| ≤ |x| ^ m / m.factorial * b₂) :
    |exp x - expNear n x a₁| ≤ |x| ^ n / n.factorial * b₁ := by
  refine (abs_sub_le _ _ _).trans ((add_le_add_right h _).trans ?_)
  subst e₁; rw [expNear_succ, expNear_sub, abs_mul]
  convert mul_le_mul_of_nonneg_left (a := |x| ^ n / ↑(Nat.factorial n))
      (le_sub_iff_add_le'.1 e) ?_ using 1
  · simp [mul_add, pow_succ', div_eq_mul_inv, abs_mul, abs_inv, ← pow_abs, mul_inv, Nat.factorial]
    ac_rfl
  · simp [div_nonneg, abs_nonneg]

theorem exp_approx_end' {n} {x a b : ℝ} (m : ℕ) (e₁ : n + 1 = m) (rm : ℝ) (er : ↑m = rm)
    (h : |x| ≤ 1) (e : |1 - a| ≤ b - |x| / rm * ((rm + 1) / rm)) :
    |exp x - expNear n x a| ≤ |x| ^ n / n.factorial * b := by
  subst er
  exact exp_approx_succ _ e₁ _ _ (by simpa using e) (exp_approx_end _ _ _ e₁ h)

theorem exp_1_approx_succ_eq {n} {a₁ b₁ : ℝ} {m : ℕ} (en : n + 1 = m) {rm : ℝ} (er : ↑m = rm)
    (h : |exp 1 - expNear m 1 ((a₁ - 1) * rm)| ≤ |1| ^ m / m.factorial * (b₁ * rm)) :
    |exp 1 - expNear n 1 a₁| ≤ |1| ^ n / n.factorial * b₁ := by
  subst er
  refine exp_approx_succ _ en _ _ ?_ h
  field_simp [show (m : ℝ) ≠ 0 by norm_cast; omega]

theorem exp_approx_start (x a b : ℝ) (h : |exp x - expNear 0 x a| ≤ |x| ^ 0 / Nat.factorial 0 * b) :
    |exp x - a| ≤ b := by simpa using h

theorem cos_bound {x : ℝ} (hx : |x| ≤ 1) : |cos x - (1 - x ^ 2 / 2)| ≤ |x| ^ 4 * (5 / 96) :=
  calc
    |cos x - (1 - x ^ 2 / 2)| = Complex.abs (Complex.cos x - (1 - (x : ℂ) ^ 2 / 2)) := by
      rw [← abs_ofReal]; simp
    _ = Complex.abs ((Complex.exp (x * I) + Complex.exp (-x * I) - (2 - (x : ℂ) ^ 2)) / 2) := by
      simp [Complex.cos, sub_div, add_div, neg_div, div_self (two_ne_zero' ℂ)]
    _ = abs
          (((Complex.exp (x * I) - ∑ m ∈ range 4, (x * I) ^ m / m.factorial) +
              (Complex.exp (-x * I) - ∑ m ∈ range 4, (-x * I) ^ m / m.factorial)) / 2) :=
      (congr_arg Complex.abs
        (congr_arg (fun x : ℂ => x / 2)
          (by
            simp only [sum_range_succ, neg_mul, pow_succ, pow_zero, mul_one, range_zero, sum_empty,
              Nat.factorial, Nat.cast_one, ne_eq, one_ne_zero, not_false_eq_true, div_self,
              zero_add, div_one, Nat.mul_one, Nat.cast_succ, Nat.cast_mul, Nat.cast_ofNat, mul_neg,
              neg_neg]
            apply Complex.ext <;> simp [div_eq_mul_inv, normSq] <;> ring_nf
            )))
    _ ≤ abs ((Complex.exp (x * I) - ∑ m ∈ range 4, (x * I) ^ m / m.factorial) / 2) +
          abs ((Complex.exp (-x * I) - ∑ m ∈ range 4, (-x * I) ^ m / m.factorial) / 2) := by
      rw [add_div]; exact Complex.abs.add_le _ _
    _ = abs (Complex.exp (x * I) - ∑ m ∈ range 4, (x * I) ^ m / m.factorial) / 2 +
          abs (Complex.exp (-x * I) - ∑ m ∈ range 4, (-x * I) ^ m / m.factorial) / 2 := by
      simp [map_div₀]
    _ ≤ Complex.abs (x * I) ^ 4 * (Nat.succ 4 * ((Nat.factorial 4) * (4 : ℕ) : ℝ)⁻¹) / 2 +
          Complex.abs (-x * I) ^ 4 * (Nat.succ 4 * ((Nat.factorial 4) * (4 : ℕ) : ℝ)⁻¹) / 2 := by
      gcongr
      · exact Complex.exp_bound (by simpa) (by decide)
      · exact Complex.exp_bound (by simpa) (by decide)
    _ ≤ |x| ^ 4 * (5 / 96) := by norm_num [Nat.factorial]

theorem sin_bound {x : ℝ} (hx : |x| ≤ 1) : |sin x - (x - x ^ 3 / 6)| ≤ |x| ^ 4 * (5 / 96) :=
  calc
    |sin x - (x - x ^ 3 / 6)| = Complex.abs (Complex.sin x - (x - x ^ 3 / 6 : ℝ)) := by
      rw [← abs_ofReal]; simp
    _ = Complex.abs (((Complex.exp (-x * I) - Complex.exp (x * I)) * I -
          (2 * x - x ^ 3 / 3 : ℝ)) / 2) := by
      simp [Complex.sin, sub_div, add_div, neg_div, mul_div_cancel_left₀ _ (two_ne_zero' ℂ),
        div_div, show (3 : ℂ) * 2 = 6 by norm_num]
    _ = Complex.abs (((Complex.exp (-x * I) - ∑ m ∈ range 4, (-x * I) ^ m / m.factorial) -
                (Complex.exp (x * I) - ∑ m ∈ range 4, (x * I) ^ m / m.factorial)) * I / 2) :=
      (congr_arg Complex.abs
        (congr_arg (fun x : ℂ => x / 2)
          (by
            simp only [sum_range_succ, neg_mul, pow_succ, pow_zero, mul_one, ofReal_sub, ofReal_mul,
              ofReal_ofNat, ofReal_div, range_zero, sum_empty, Nat.factorial, Nat.cast_one, ne_eq,
              one_ne_zero, not_false_eq_true, div_self, zero_add, div_one, mul_neg, neg_neg,
              Nat.mul_one, Nat.cast_succ, Nat.cast_mul, Nat.cast_ofNat]
            apply Complex.ext <;> simp [div_eq_mul_inv, normSq]; ring)))
    _ ≤ abs ((Complex.exp (-x * I) - ∑ m ∈ range 4, (-x * I) ^ m / m.factorial) * I / 2) +
          abs (-((Complex.exp (x * I) - ∑ m ∈ range 4, (x * I) ^ m / m.factorial) * I) / 2) := by
      rw [sub_mul, sub_eq_add_neg, add_div]; exact Complex.abs.add_le _ _
    _ = abs (Complex.exp (x * I) - ∑ m ∈ range 4, (x * I) ^ m / m.factorial) / 2 +
          abs (Complex.exp (-x * I) - ∑ m ∈ range 4, (-x * I) ^ m / m.factorial) / 2 := by
      simp [add_comm, map_div₀]
    _ ≤ Complex.abs (x * I) ^ 4 * (Nat.succ 4 * (Nat.factorial 4 * (4 : ℕ) : ℝ)⁻¹) / 2 +
          Complex.abs (-x * I) ^ 4 * (Nat.succ 4 * (Nat.factorial 4 * (4 : ℕ) : ℝ)⁻¹) / 2 := by
      gcongr
      · exact Complex.exp_bound (by simpa) (by decide)
      · exact Complex.exp_bound (by simpa) (by decide)
    _ ≤ |x| ^ 4 * (5 / 96) := by norm_num [Nat.factorial]

theorem cos_pos_of_le_one {x : ℝ} (hx : |x| ≤ 1) : 0 < cos x :=
  calc 0 < 1 - x ^ 2 / 2 - |x| ^ 4 * (5 / 96) :=
      sub_pos.2 <|
        lt_sub_iff_add_lt.2
          (calc
            |x| ^ 4 * (5 / 96) + x ^ 2 / 2 ≤ 1 * (5 / 96) + 1 / 2 := by
                  gcongr
                  · exact pow_le_one₀ (abs_nonneg _) hx
                  · rw [sq, ← abs_mul_self, abs_mul]
                    exact mul_le_one₀ hx (abs_nonneg _) hx
            _ < 1 := by norm_num)
    _ ≤ cos x := sub_le_comm.1 (abs_sub_le_iff.1 (cos_bound hx)).2

theorem sin_pos_of_pos_of_le_one {x : ℝ} (hx0 : 0 < x) (hx : x ≤ 1) : 0 < sin x :=
  calc 0 < x - x ^ 3 / 6 - |x| ^ 4 * (5 / 96) :=
      sub_pos.2 <| lt_sub_iff_add_lt.2
          (calc
            |x| ^ 4 * (5 / 96) + x ^ 3 / 6 ≤ x * (5 / 96) + x / 6 := by
                gcongr
                · calc
                    |x| ^ 4 ≤ |x| ^ 1 :=
                      pow_le_pow_of_le_one (abs_nonneg _)
                        (by rwa [_root_.abs_of_nonneg (le_of_lt hx0)]) (by decide)
                    _ = x := by simp [_root_.abs_of_nonneg (le_of_lt hx0)]
                · calc
                    x ^ 3 ≤ x ^ 1 := pow_le_pow_of_le_one (le_of_lt hx0) hx (by decide)
                    _ = x := pow_one _
            _ < x := by linarith)
    _ ≤ sin x :=
      sub_le_comm.1 (abs_sub_le_iff.1 (sin_bound (by rwa [_root_.abs_of_nonneg (le_of_lt hx0)]))).2

theorem sin_pos_of_pos_of_le_two {x : ℝ} (hx0 : 0 < x) (hx : x ≤ 2) : 0 < sin x :=
  have : x / 2 ≤ 1 := (div_le_iff₀ (by norm_num)).mpr (by simpa)
  calc
    0 < 2 * sin (x / 2) * cos (x / 2) :=
      mul_pos (mul_pos (by norm_num) (sin_pos_of_pos_of_le_one (half_pos hx0) this))
        (cos_pos_of_le_one (by rwa [_root_.abs_of_nonneg (le_of_lt (half_pos hx0))]))
    _ = sin x := by rw [← sin_two_mul, two_mul, add_halves]

theorem cos_one_le : cos 1 ≤ 2 / 3 :=
  calc
    cos 1 ≤ |(1 : ℝ)| ^ 4 * (5 / 96) + (1 - 1 ^ 2 / 2) :=
      sub_le_iff_le_add.1 (abs_sub_le_iff.1 (cos_bound (by simp))).1
    _ ≤ 2 / 3 := by norm_num

theorem cos_one_pos : 0 < cos 1 :=
  cos_pos_of_le_one (le_of_eq abs_one)

theorem cos_two_neg : cos 2 < 0 :=
  calc cos 2 = cos (2 * 1) := congr_arg cos (mul_one _).symm
    _ = _ := Real.cos_two_mul 1
    _ ≤ 2 * (2 / 3) ^ 2 - 1 := by
      gcongr
      · exact cos_one_pos.le
      · apply cos_one_le
    _ < 0 := by norm_num

theorem exp_bound_div_one_sub_of_interval' {x : ℝ} (h1 : 0 < x) (h2 : x < 1) :
    Real.exp x < 1 / (1 - x) := by
  have H : 0 < 1 - (1 + x + x ^ 2) * (1 - x) := calc
    0 < x ^ 3 := by positivity
    _ = 1 - (1 + x + x ^ 2) * (1 - x) := by ring
  calc
    exp x ≤ _ := exp_bound' h1.le h2.le zero_lt_three
    _ ≤ 1 + x + x ^ 2 := by
      -- Porting note: was `norm_num [Finset.sum] <;> nlinarith`
      -- This proof should be restored after the norm_num plugin for big operators is ported.
      -- (It may also need the positivity extensions in #3907.)
      erw [Finset.sum_range_succ]
      repeat rw [Finset.sum_range_succ]
      norm_num [Nat.factorial]
      nlinarith
    _ < 1 / (1 - x) := by rw [lt_div_iff₀] <;> nlinarith

theorem exp_bound_div_one_sub_of_interval {x : ℝ} (h1 : 0 ≤ x) (h2 : x < 1) :
    Real.exp x ≤ 1 / (1 - x) := by
  rcases eq_or_lt_of_le h1 with (rfl | h1)
  · simp
  · exact (exp_bound_div_one_sub_of_interval' h1 h2).le

theorem add_one_lt_exp {x : ℝ} (hx : x ≠ 0) : x + 1 < Real.exp x := by
  obtain hx | hx := hx.symm.lt_or_lt
  · exact add_one_lt_exp_of_pos hx
  obtain h' | h' := le_or_lt 1 (-x)
  · linarith [x.exp_pos]
  have hx' : 0 < x + 1 := by linarith
  simpa [add_comm, exp_neg, inv_lt_inv₀ (exp_pos _) hx']
    using exp_bound_div_one_sub_of_interval' (neg_pos.2 hx) h'

theorem add_one_le_exp (x : ℝ) : x + 1 ≤ Real.exp x := by
  obtain rfl | hx := eq_or_ne x 0
  · simp
  · exact (add_one_lt_exp hx).le

lemma one_sub_lt_exp_neg {x : ℝ} (hx : x ≠ 0) : 1 - x < exp (-x) :=
  (sub_eq_neg_add _ _).trans_lt <| add_one_lt_exp <| neg_ne_zero.2 hx

lemma one_sub_le_exp_neg (x : ℝ) : 1 - x ≤ exp (-x) :=
  (sub_eq_neg_add _ _).trans_le <| add_one_le_exp _

theorem one_sub_div_pow_le_exp_neg {n : ℕ} {t : ℝ} (ht' : t ≤ n) : (1 - t / n) ^ n ≤ exp (-t) := by
  rcases eq_or_ne n 0 with (rfl | hn)
  · simp
    rwa [Nat.cast_zero] at ht'
  convert pow_le_pow_left ?_ (one_sub_le_exp_neg (t / n)) n using 2
  · rw [← Real.exp_nat_mul]
    congr 1
    field_simp
    ring_nf
  · rwa [sub_nonneg, div_le_one]
    positivity

end Real

namespace Mathlib.Meta.Positivity
open Lean.Meta Qq

/-- Extension for the `positivity` tactic: `Real.exp` is always positive. -/
@[positivity Real.exp _]
def evalExp : PositivityExt where eval {u α} _ _ e := do
  match u, α, e with
  | 0, ~q(ℝ), ~q(Real.exp $a) =>
    assertInstancesCommute
    pure (.positive q(Real.exp_pos $a))
  | _, _, _ => throwError "not Real.exp"

/-- Extension for the `positivity` tactic: `Real.cosh` is always positive. -/
@[positivity Real.cosh _]
def evalCosh : PositivityExt where eval {u α} _ _ e := do
  match u, α, e with
  | 0, ~q(ℝ), ~q(Real.cosh $a) =>
    assertInstancesCommute
    return .positive q(Real.cosh_pos $a)
  | _, _, _ => throwError "not Real.cosh"

example (x : ℝ) : 0 < x.cosh := by positivity

end Mathlib.Meta.Positivity

namespace Complex

@[simp]
theorem abs_cos_add_sin_mul_I (x : ℝ) : abs (cos x + sin x * I) = 1 := by
  have := Real.sin_sq_add_cos_sq x
  simp_all [add_comm, abs, normSq, sq, sin_ofReal_re, cos_ofReal_re, mul_re]

@[simp]
theorem abs_exp_ofReal (x : ℝ) : abs (exp x) = Real.exp x := by
  rw [← ofReal_exp]
  exact abs_of_nonneg (le_of_lt (Real.exp_pos _))

@[simp]
theorem abs_exp_ofReal_mul_I (x : ℝ) : abs (exp (x * I)) = 1 := by
  rw [exp_mul_I, abs_cos_add_sin_mul_I]

theorem abs_exp (z : ℂ) : abs (exp z) = Real.exp z.re := by
  rw [exp_eq_exp_re_mul_sin_add_cos, map_mul, abs_exp_ofReal, abs_cos_add_sin_mul_I, mul_one]

theorem abs_exp_eq_iff_re_eq {x y : ℂ} : abs (exp x) = abs (exp y) ↔ x.re = y.re := by
  rw [abs_exp, abs_exp, Real.exp_eq_exp]

end Complex
