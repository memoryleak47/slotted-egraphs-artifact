import Mathlib.Testing.Egg.SimpOnlyOverride
/-
Copyright (c) 2018 Chris Hughes. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Hughes, Johannes Hölzl, Kim Morrison, Jens Wagemaker
-/
import Mathlib.Algebra.MonoidAlgebra.Degree
import Mathlib.Algebra.Polynomial.Coeff
import Mathlib.Algebra.Polynomial.Monomial
import Mathlib.Data.Fintype.BigOperators
import Mathlib.Data.Nat.WithBot
import Mathlib.Data.Nat.Cast.WithTop
import Mathlib.Data.Nat.SuccPred
import Mathlib.Algebra.Order.Ring.WithTop

/-!
# Theory of univariate polynomials

The definitions include
`degree`, `Monic`, `leadingCoeff`

Results include
- `degree_mul` : The degree of the product is the sum of degrees
- `leadingCoeff_add_of_degree_eq` and `leadingCoeff_add_of_degree_lt` :
    The leading_coefficient of a sum is determined by the leading coefficients and degrees
-/

-- Porting note: `Mathlib.Data.Nat.Cast.WithTop` should be imported for `Nat.cast_withBot`.


noncomputable section

open Finsupp Finset

open Polynomial

namespace Polynomial

universe u v

variable {R : Type u} {S : Type v} {a b c d : R} {n m : ℕ}

section Semiring

variable [Semiring R] {p q r : R[X]}

/-- `degree p` is the degree of the polynomial `p`, i.e. the largest `X`-exponent in `p`.
`degree p = some n` when `p ≠ 0` and `n` is the highest power of `X` that appears in `p`, otherwise
`degree 0 = ⊥`. -/
def degree (p : R[X]) : WithBot ℕ :=
  p.support.max

theorem supDegree_eq_degree (p : R[X]) : p.toFinsupp.supDegree WithBot.some = p.degree :=
  max_eq_sup_coe

theorem degree_lt_wf : WellFounded fun p q : R[X] => degree p < degree q :=
  InvImage.wf degree wellFounded_lt

instance : WellFoundedRelation R[X] :=
  ⟨_, degree_lt_wf⟩

/-- `natDegree p` forces `degree p` to ℕ, by defining `natDegree 0 = 0`. -/
def natDegree (p : R[X]) : ℕ :=
  (degree p).unbot' 0

/-- `leadingCoeff p` gives the coefficient of the highest power of `X` in `p`-/
def leadingCoeff (p : R[X]) : R :=
  coeff p (natDegree p)

/-- a polynomial is `Monic` if its leading coefficient is 1 -/
def Monic (p : R[X]) :=
  leadingCoeff p = (1 : R)

@[nontriviality]
theorem monic_of_subsingleton [Subsingleton R] (p : R[X]) : Monic p :=
  Subsingleton.elim _ _

theorem Monic.def : Monic p ↔ leadingCoeff p = 1 :=
  Iff.rfl

instance Monic.decidable [DecidableEq R] : Decidable (Monic p) := by unfold Monic; infer_instance

@[simp]
theorem Monic.leadingCoeff {p : R[X]} (hp : p.Monic) : leadingCoeff p = 1 :=
  hp

theorem Monic.coeff_natDegree {p : R[X]} (hp : p.Monic) : p.coeff p.natDegree = 1 :=
  hp

@[simp]
theorem degree_zero : degree (0 : R[X]) = ⊥ :=
  rfl

@[simp]
theorem natDegree_zero : natDegree (0 : R[X]) = 0 :=
  rfl

@[simp]
theorem coeff_natDegree : coeff p (natDegree p) = leadingCoeff p :=
  rfl

@[simp]
theorem degree_eq_bot : degree p = ⊥ ↔ p = 0 :=
  ⟨fun h => support_eq_empty.1 (Finset.max_eq_bot.1 h), fun h => h.symm ▸ rfl⟩

theorem degree_ne_bot : degree p ≠ ⊥ ↔ p ≠ 0 := degree_eq_bot.not

@[nontriviality]
theorem degree_of_subsingleton [Subsingleton R] : degree p = ⊥ := by
  rw [Subsingleton.elim p 0, degree_zero]

@[nontriviality]
theorem natDegree_of_subsingleton [Subsingleton R] : natDegree p = 0 := by
  rw [Subsingleton.elim p 0, natDegree_zero]

theorem degree_eq_natDegree (hp : p ≠ 0) : degree p = (natDegree p : WithBot ℕ) := by
  let ⟨n, hn⟩ := not_forall.1 (mt Option.eq_none_iff_forall_not_mem.2 (mt degree_eq_bot.1 hp))
  have hn : degree p = some n := Classical.not_not.1 hn
  rw [natDegree, hn]; rfl

theorem supDegree_eq_natDegree (p : R[X]) : p.toFinsupp.supDegree id = p.natDegree := by
  obtain rfl|h := eq_or_ne p 0
  · simp
  apply WithBot.coe_injective
  rw [← AddMonoidAlgebra.supDegree_withBot_some_comp, Function.comp_id, supDegree_eq_degree,
    degree_eq_natDegree h, Nat.cast_withBot]
  rwa [support_toFinsupp, nonempty_iff_ne_empty, Ne, support_eq_empty]

theorem degree_eq_iff_natDegree_eq {p : R[X]} {n : ℕ} (hp : p ≠ 0) :
    p.degree = n ↔ p.natDegree = n := by rw [degree_eq_natDegree hp]; exact WithBot.coe_eq_coe

theorem degree_eq_iff_natDegree_eq_of_pos {p : R[X]} {n : ℕ} (hn : 0 < n) :
    p.degree = n ↔ p.natDegree = n := by
  obtain rfl|h := eq_or_ne p 0
  · simp [hn.ne]
  · exact degree_eq_iff_natDegree_eq h

theorem natDegree_eq_of_degree_eq_some {p : R[X]} {n : ℕ} (h : degree p = n) : natDegree p = n := by
  -- Porting note: `Nat.cast_withBot` is required.
  rw [natDegree, h, Nat.cast_withBot, WithBot.unbot'_coe]

theorem degree_ne_of_natDegree_ne {n : ℕ} : p.natDegree ≠ n → degree p ≠ n :=
  mt natDegree_eq_of_degree_eq_some

@[simp]
theorem degree_le_natDegree : degree p ≤ natDegree p :=
  WithBot.giUnbot'Bot.gc.le_u_l _

theorem natDegree_eq_of_degree_eq [Semiring S] {q : S[X]} (h : degree p = degree q) :
    natDegree p = natDegree q := by unfold natDegree; rw [h]

theorem le_degree_of_ne_zero (h : coeff p n ≠ 0) : (n : WithBot ℕ) ≤ degree p := by
  rw [Nat.cast_withBot]
  exact Finset.le_sup (mem_support_iff.2 h)

theorem le_natDegree_of_ne_zero (h : coeff p n ≠ 0) : n ≤ natDegree p := by
  rw [← Nat.cast_le (α := WithBot ℕ), ← degree_eq_natDegree]
  · exact le_degree_of_ne_zero h
  · rintro rfl
    exact h rfl

theorem le_natDegree_of_mem_supp (a : ℕ) : a ∈ p.support → a ≤ natDegree p :=
  le_natDegree_of_ne_zero ∘ mem_support_iff.mp

theorem degree_eq_of_le_of_coeff_ne_zero (pn : p.degree ≤ n) (p1 : p.coeff n ≠ 0) : p.degree = n :=
  pn.antisymm (le_degree_of_ne_zero p1)

theorem natDegree_eq_of_le_of_coeff_ne_zero (pn : p.natDegree ≤ n) (p1 : p.coeff n ≠ 0) :
    p.natDegree = n :=
  pn.antisymm (le_natDegree_of_ne_zero p1)

theorem degree_mono [Semiring S] {f : R[X]} {g : S[X]} (h : f.support ⊆ g.support) :
    f.degree ≤ g.degree :=
  Finset.sup_mono h

theorem supp_subset_range (h : natDegree p < m) : p.support ⊆ Finset.range m := fun _n hn =>
  mem_range.2 <| (le_natDegree_of_mem_supp _ hn).trans_lt h

theorem supp_subset_range_natDegree_succ : p.support ⊆ Finset.range (natDegree p + 1) :=
  supp_subset_range (Nat.lt_succ_self _)

theorem degree_le_degree (h : coeff q (natDegree p) ≠ 0) : degree p ≤ degree q := by
  by_cases hp : p = 0
  · rw [hp, degree_zero]
    exact bot_le
  · rw [degree_eq_natDegree hp]
    exact le_degree_of_ne_zero h

theorem natDegree_le_iff_degree_le {n : ℕ} : natDegree p ≤ n ↔ degree p ≤ n :=
  WithBot.unbot'_le_iff (fun _ ↦ bot_le)

theorem natDegree_lt_iff_degree_lt (hp : p ≠ 0) : p.natDegree < n ↔ p.degree < ↑n :=
  WithBot.unbot'_lt_iff (absurd · (degree_eq_bot.not.mpr hp))

alias ⟨degree_le_of_natDegree_le, natDegree_le_of_degree_le⟩ := natDegree_le_iff_degree_le

theorem natDegree_le_natDegree [Semiring S] {q : S[X]} (hpq : p.degree ≤ q.degree) :
    p.natDegree ≤ q.natDegree :=
  WithBot.giUnbot'Bot.gc.monotone_l hpq

theorem natDegree_lt_natDegree {p q : R[X]} (hp : p ≠ 0) (hpq : p.degree < q.degree) :
    p.natDegree < q.natDegree := by
  by_cases hq : q = 0
  · exact (not_lt_bot <| hq ▸ hpq).elim
  rwa [degree_eq_natDegree hp, degree_eq_natDegree hq, Nat.cast_lt] at hpq

@[simp]
theorem degree_C (ha : a ≠ 0) : degree (C a) = (0 : WithBot ℕ) := by
  rw [degree, ← monomial_zero_left, support_monomial 0 ha, max_eq_sup_coe, sup_singleton,
    WithBot.coe_zero]

theorem degree_C_le : degree (C a) ≤ 0 := by
  by_cases h : a = 0
  · rw [h, C_0]
    exact bot_le
  · rw [degree_C h]

theorem degree_C_lt : degree (C a) < 1 :=
  degree_C_le.trans_lt <| WithBot.coe_lt_coe.mpr zero_lt_one

theorem degree_one_le : degree (1 : R[X]) ≤ (0 : WithBot ℕ) := by rw [← C_1]; exact degree_C_le

@[simp]
theorem natDegree_C (a : R) : natDegree (C a) = 0 := by
  by_cases ha : a = 0
  · have : C a = 0 := by rw [ha, C_0]
    rw [natDegree, degree_eq_bot.2 this, WithBot.unbot'_bot]
  · rw [natDegree, degree_C ha, WithBot.unbot_zero']

@[simp]
theorem natDegree_one : natDegree (1 : R[X]) = 0 :=
  natDegree_C 1

@[simp]
theorem natDegree_natCast (n : ℕ) : natDegree (n : R[X]) = 0 := by
  simp only [← C_eq_natCast, natDegree_C]

@[deprecated (since := "2024-04-17")]
alias natDegree_nat_cast := natDegree_natCast

-- See note [no_index around OfNat.ofNat]
@[simp]
theorem natDegree_ofNat (n : ℕ) [Nat.AtLeastTwo n] :
    natDegree (no_index (OfNat.ofNat n : R[X])) = 0 :=
  natDegree_natCast _

theorem degree_natCast_le (n : ℕ) : degree (n : R[X]) ≤ 0 := degree_le_of_natDegree_le (by simp)

@[deprecated (since := "2024-04-17")]
alias degree_nat_cast_le := degree_natCast_le

@[simp]
theorem degree_monomial (n : ℕ) (ha : a ≠ 0) : degree (monomial n a) = n := by
  rw [degree, support_monomial n ha, max_singleton, Nat.cast_withBot]

@[simp]
theorem degree_C_mul_X_pow (n : ℕ) (ha : a ≠ 0) : degree (C a * X ^ n) = n := by
  rw [C_mul_X_pow_eq_monomial, degree_monomial n ha]

theorem degree_C_mul_X (ha : a ≠ 0) : degree (C a * X) = 1 := by
  simpa only [pow_one] using degree_C_mul_X_pow 1 ha

theorem degree_monomial_le (n : ℕ) (a : R) : degree (monomial n a) ≤ n :=
  letI := Classical.decEq R
  if h : a = 0 then by rw [h, (monomial n).map_zero, degree_zero]; exact bot_le
  else le_of_eq (degree_monomial n h)

theorem degree_C_mul_X_pow_le (n : ℕ) (a : R) : degree (C a * X ^ n) ≤ n := by
  rw [C_mul_X_pow_eq_monomial]
  apply degree_monomial_le

theorem degree_C_mul_X_le (a : R) : degree (C a * X) ≤ 1 := by
  simpa only [pow_one] using degree_C_mul_X_pow_le 1 a

@[simp]
theorem natDegree_C_mul_X_pow (n : ℕ) (a : R) (ha : a ≠ 0) : natDegree (C a * X ^ n) = n :=
  natDegree_eq_of_degree_eq_some (degree_C_mul_X_pow n ha)

@[simp]
theorem natDegree_C_mul_X (a : R) (ha : a ≠ 0) : natDegree (C a * X) = 1 := by
  simpa only [pow_one] using natDegree_C_mul_X_pow 1 a ha

@[simp]
theorem natDegree_monomial [DecidableEq R] (i : ℕ) (r : R) :
    natDegree (monomial i r) = if r = 0 then 0 else i := by
  split_ifs with hr
  · simp [hr]
  · rw [← C_mul_X_pow_eq_monomial, natDegree_C_mul_X_pow i r hr]

theorem natDegree_monomial_le (a : R) {m : ℕ} : (monomial m a).natDegree ≤ m := by
  classical
  rw [Polynomial.natDegree_monomial]
  split_ifs
  exacts [Nat.zero_le _, le_rfl]

theorem natDegree_monomial_eq (i : ℕ) {r : R} (r0 : r ≠ 0) : (monomial i r).natDegree = i :=
  letI := Classical.decEq R
  Eq.trans (natDegree_monomial _ _) (if_neg r0)

theorem coeff_eq_zero_of_degree_lt (h : degree p < n) : coeff p n = 0 :=
  Classical.not_not.1 (mt le_degree_of_ne_zero (not_le_of_gt h))

theorem coeff_eq_zero_of_natDegree_lt {p : R[X]} {n : ℕ} (h : p.natDegree < n) :
    p.coeff n = 0 := by
  apply coeff_eq_zero_of_degree_lt
  by_cases hp : p = 0
  · subst hp
    exact WithBot.bot_lt_coe n
  · rwa [degree_eq_natDegree hp, Nat.cast_lt]

theorem ext_iff_natDegree_le {p q : R[X]} {n : ℕ} (hp : p.natDegree ≤ n) (hq : q.natDegree ≤ n) :
    p = q ↔ ∀ i ≤ n, p.coeff i = q.coeff i := by
  refine Iff.trans Polynomial.ext_iff ?_
  refine forall_congr' fun i => ⟨fun h _ => h, fun h => ?_⟩
  refine (le_or_lt i n).elim h fun k => ?_
  exact
    (coeff_eq_zero_of_natDegree_lt (hp.trans_lt k)).trans
      (coeff_eq_zero_of_natDegree_lt (hq.trans_lt k)).symm

theorem ext_iff_degree_le {p q : R[X]} {n : ℕ} (hp : p.degree ≤ n) (hq : q.degree ≤ n) :
    p = q ↔ ∀ i ≤ n, p.coeff i = q.coeff i :=
  ext_iff_natDegree_le (natDegree_le_of_degree_le hp) (natDegree_le_of_degree_le hq)

@[simp]
theorem coeff_natDegree_succ_eq_zero {p : R[X]} : p.coeff (p.natDegree + 1) = 0 :=
  coeff_eq_zero_of_natDegree_lt (lt_add_one _)

-- We need the explicit `Decidable` argument here because an exotic one shows up in a moment!
theorem ite_le_natDegree_coeff (p : R[X]) (n : ℕ) (I : Decidable (n < 1 + natDegree p)) :
    @ite _ (n < 1 + natDegree p) I (coeff p n) 0 = coeff p n := by
  split_ifs with h
  · rfl
  · exact (coeff_eq_zero_of_natDegree_lt (not_le.1 fun w => h (Nat.lt_one_add_iff.2 w))).symm

theorem as_sum_support (p : R[X]) : p = ∑ i ∈ p.support, monomial i (p.coeff i) :=
  (sum_monomial_eq p).symm

theorem as_sum_support_C_mul_X_pow (p : R[X]) : p = ∑ i ∈ p.support, C (p.coeff i) * X ^ i :=
  _root_.trans p.as_sum_support <| by simp only [C_mul_X_pow_eq_monomial]

/-- We can reexpress a sum over `p.support` as a sum over `range n`,
for any `n` satisfying `p.natDegree < n`.
-/
theorem sum_over_range' [AddCommMonoid S] (p : R[X]) {f : ℕ → R → S} (h : ∀ n, f n 0 = 0) (n : ℕ)
    (w : p.natDegree < n) : p.sum f = ∑ a ∈ range n, f a (coeff p a) := by
  rcases p with ⟨⟩
  have := supp_subset_range w
  simp only [Polynomial.sum, support, coeff, natDegree, degree] at this ⊢
  exact Finsupp.sum_of_support_subset _ this _ fun n _hn => h n

/-- We can reexpress a sum over `p.support` as a sum over `range (p.natDegree + 1)`.
-/
theorem sum_over_range [AddCommMonoid S] (p : R[X]) {f : ℕ → R → S} (h : ∀ n, f n 0 = 0) :
    p.sum f = ∑ a ∈ range (p.natDegree + 1), f a (coeff p a) :=
  sum_over_range' p h (p.natDegree + 1) (lt_add_one _)

-- TODO this is essentially a duplicate of `sum_over_range`, and should be removed.
theorem sum_fin [AddCommMonoid S] (f : ℕ → R → S) (hf : ∀ i, f i 0 = 0) {n : ℕ} {p : R[X]}
    (hn : p.degree < n) : (∑ i : Fin n, f i (p.coeff i)) = p.sum f := by
  by_cases hp : p = 0
  · rw [hp, sum_zero_index, Finset.sum_eq_zero]
    intro i _
    exact hf i
  rw [sum_over_range' _ hf n ((natDegree_lt_iff_degree_lt hp).mpr hn),
    Fin.sum_univ_eq_sum_range fun i => f i (p.coeff i)]

theorem as_sum_range' (p : R[X]) (n : ℕ) (w : p.natDegree < n) :
    p = ∑ i ∈ range n, monomial i (coeff p i) :=
  p.sum_monomial_eq.symm.trans <| p.sum_over_range' monomial_zero_right _ w

theorem as_sum_range (p : R[X]) : p = ∑ i ∈ range (p.natDegree + 1), monomial i (coeff p i) :=
  p.sum_monomial_eq.symm.trans <| p.sum_over_range <| monomial_zero_right

theorem as_sum_range_C_mul_X_pow (p : R[X]) :
    p = ∑ i ∈ range (p.natDegree + 1), C (coeff p i) * X ^ i :=
  p.as_sum_range.trans <| by simp only [C_mul_X_pow_eq_monomial]

theorem coeff_ne_zero_of_eq_degree (hn : degree p = n) : coeff p n ≠ 0 := fun h =>
  mem_support_iff.mp (mem_of_max hn) h

theorem eq_X_add_C_of_degree_le_one (h : degree p ≤ 1) : p = C (p.coeff 1) * X + C (p.coeff 0) :=
  ext fun n =>
    Nat.casesOn n (by simp) fun n =>
      Nat.casesOn n (by simp [coeff_C]) fun m => by
        -- Porting note: `by decide` → `Iff.mpr ..`
        have : degree p < m.succ.succ := lt_of_le_of_lt h
          (Iff.mpr WithBot.coe_lt_coe <| Nat.succ_lt_succ <| Nat.zero_lt_succ m)
        simp [coeff_eq_zero_of_degree_lt this, coeff_C, Nat.succ_ne_zero, coeff_X, Nat.succ_inj',
          @eq_comm ℕ 0]

theorem eq_X_add_C_of_degree_eq_one (h : degree p = 1) :
    p = C p.leadingCoeff * X + C (p.coeff 0) :=
  (eq_X_add_C_of_degree_le_one h.le).trans
    (by rw [← Nat.cast_one] at h; rw [leadingCoeff, natDegree_eq_of_degree_eq_some h])

theorem eq_X_add_C_of_natDegree_le_one (h : natDegree p ≤ 1) :
    p = C (p.coeff 1) * X + C (p.coeff 0) :=
  eq_X_add_C_of_degree_le_one <| degree_le_of_natDegree_le h

theorem Monic.eq_X_add_C (hm : p.Monic) (hnd : p.natDegree = 1) : p = X + C (p.coeff 0) := by
  rw [← one_mul X, ← C_1, ← hm.coeff_natDegree, hnd, ← eq_X_add_C_of_natDegree_le_one hnd.le]

theorem exists_eq_X_add_C_of_natDegree_le_one (h : natDegree p ≤ 1) : ∃ a b, p = C a * X + C b :=
  ⟨p.coeff 1, p.coeff 0, eq_X_add_C_of_natDegree_le_one h⟩

theorem degree_X_pow_le (n : ℕ) : degree (X ^ n : R[X]) ≤ n := by
  simpa only [C_1, one_mul] using degree_C_mul_X_pow_le n (1 : R)

theorem degree_X_le : degree (X : R[X]) ≤ 1 :=
  degree_monomial_le _ _

theorem natDegree_X_le : (X : R[X]).natDegree ≤ 1 :=
  natDegree_le_of_degree_le degree_X_le

theorem mem_support_C_mul_X_pow {n a : ℕ} {c : R} (h : a ∈ support (C c * X ^ n)) : a = n :=
  mem_singleton.1 <| support_C_mul_X_pow' n c h

theorem card_support_C_mul_X_pow_le_one {c : R} {n : ℕ} : #(support (C c * X ^ n)) ≤ 1 := by
  rw [← card_singleton n]
  apply card_le_card (support_C_mul_X_pow' n c)

theorem card_supp_le_succ_natDegree (p : R[X]) : #p.support ≤ p.natDegree + 1 := by
  rw [← Finset.card_range (p.natDegree + 1)]
  exact Finset.card_le_card supp_subset_range_natDegree_succ

theorem le_degree_of_mem_supp (a : ℕ) : a ∈ p.support → ↑a ≤ degree p :=
  le_degree_of_ne_zero ∘ mem_support_iff.mp

theorem nonempty_support_iff : p.support.Nonempty ↔ p ≠ 0 := by
  rw [Ne, nonempty_iff_ne_empty, Ne, ← support_eq_empty]

end Semiring

section NonzeroSemiring

variable [Semiring R] [Nontrivial R] {p q : R[X]}

@[simp]
theorem degree_one : degree (1 : R[X]) = (0 : WithBot ℕ) :=
  degree_C one_ne_zero

@[simp]
theorem degree_X : degree (X : R[X]) = 1 :=
  degree_monomial _ one_ne_zero

@[simp]
theorem natDegree_X : (X : R[X]).natDegree = 1 :=
  natDegree_eq_of_degree_eq_some degree_X

end NonzeroSemiring

section Ring

variable [Ring R]

theorem coeff_mul_X_sub_C {p : R[X]} {r : R} {a : ℕ} :
    coeff (p * (X - C r)) (a + 1) = coeff p a - coeff p (a + 1) * r := by simp [mul_sub]

@[simp]
theorem degree_neg (p : R[X]) : degree (-p) = degree p := by unfold degree; rw [support_neg]

theorem degree_neg_le_of_le {a : WithBot ℕ} {p : R[X]} (hp : degree p ≤ a) : degree (-p) ≤ a :=
  p.degree_neg.le.trans hp

@[simp]
theorem natDegree_neg (p : R[X]) : natDegree (-p) = natDegree p := by simp [natDegree]

theorem natDegree_neg_le_of_le {p : R[X]} (hp : natDegree p ≤ m) : natDegree (-p) ≤ m :=
  (natDegree_neg p).le.trans hp

@[simp]
theorem natDegree_intCast (n : ℤ) : natDegree (n : R[X]) = 0 := by
  rw [← C_eq_intCast, natDegree_C]

@[deprecated (since := "2024-04-17")]
alias natDegree_int_cast := natDegree_intCast

theorem degree_intCast_le (n : ℤ) : degree (n : R[X]) ≤ 0 := degree_le_of_natDegree_le (by simp)

@[deprecated (since := "2024-04-17")]
alias degree_int_cast_le := degree_intCast_le

@[simp]
theorem leadingCoeff_neg (p : R[X]) : (-p).leadingCoeff = -p.leadingCoeff := by
  rw [leadingCoeff, leadingCoeff, natDegree_neg, coeff_neg]

end Ring

section Semiring

variable [Semiring R] {p : R[X]}

/-- The second-highest coefficient, or 0 for constants -/
def nextCoeff (p : R[X]) : R :=
  if p.natDegree = 0 then 0 else p.coeff (p.natDegree - 1)

lemma nextCoeff_eq_zero :
    p.nextCoeff = 0 ↔ p.natDegree = 0 ∨ 0 < p.natDegree ∧ p.coeff (p.natDegree - 1) = 0 := by
  simp [nextCoeff, or_iff_not_imp_left, pos_iff_ne_zero]; aesop

lemma nextCoeff_ne_zero : p.nextCoeff ≠ 0 ↔ p.natDegree ≠ 0 ∧ p.coeff (p.natDegree - 1) ≠ 0 := by
  simp [nextCoeff]

@[simp]
theorem nextCoeff_C_eq_zero (c : R) : nextCoeff (C c) = 0 := by
  rw [nextCoeff]
  simp

theorem nextCoeff_of_natDegree_pos (hp : 0 < p.natDegree) :
    nextCoeff p = p.coeff (p.natDegree - 1) := by
  rw [nextCoeff, if_neg]
  contrapose! hp
  simpa

variable {p q : R[X]} {ι : Type*}

theorem coeff_natDegree_eq_zero_of_degree_lt (h : degree p < degree q) :
    coeff p (natDegree q) = 0 :=
  coeff_eq_zero_of_degree_lt (lt_of_lt_of_le h degree_le_natDegree)

theorem ne_zero_of_degree_gt {n : WithBot ℕ} (h : n < degree p) : p ≠ 0 :=
  mt degree_eq_bot.2 h.ne_bot

theorem ne_zero_of_degree_ge_degree (hpq : p.degree ≤ q.degree) (hp : p ≠ 0) : q ≠ 0 :=
  Polynomial.ne_zero_of_degree_gt
    (lt_of_lt_of_le (bot_lt_iff_ne_bot.mpr (by rwa [Ne, Polynomial.degree_eq_bot])) hpq :
      q.degree > ⊥)

theorem ne_zero_of_natDegree_gt {n : ℕ} (h : n < natDegree p) : p ≠ 0 := fun H => by
  simp [H, Nat.not_lt_zero] at h

theorem degree_lt_degree (h : natDegree p < natDegree q) : degree p < degree q := by
  by_cases hp : p = 0
  · simp only [hp, degree_zero]
    rw [bot_lt_iff_ne_bot]
    intro hq
    simp [hp, degree_eq_bot.mp hq, lt_irrefl] at h
  · rwa [degree_eq_natDegree hp, degree_eq_natDegree <| ne_zero_of_natDegree_gt h, Nat.cast_lt]

theorem natDegree_lt_natDegree_iff (hp : p ≠ 0) : natDegree p < natDegree q ↔ degree p < degree q :=
  ⟨degree_lt_degree, fun h ↦ by
    have hq : q ≠ 0 := ne_zero_of_degree_gt h
    rwa [degree_eq_natDegree hp, degree_eq_natDegree hq, Nat.cast_lt] at h⟩

theorem eq_C_of_degree_le_zero (h : degree p ≤ 0) : p = C (coeff p 0) := by
  ext (_ | n)
  · simp
  rw [coeff_C, if_neg (Nat.succ_ne_zero _), coeff_eq_zero_of_degree_lt]
  exact h.trans_lt (WithBot.coe_lt_coe.2 n.succ_pos)

theorem eq_C_of_degree_eq_zero (h : degree p = 0) : p = C (coeff p 0) :=
  eq_C_of_degree_le_zero h.le

theorem degree_le_zero_iff : degree p ≤ 0 ↔ p = C (coeff p 0) :=
  ⟨eq_C_of_degree_le_zero, fun h => h.symm ▸ degree_C_le⟩

theorem degree_add_le (p q : R[X]) : degree (p + q) ≤ max (degree p) (degree q) := by
  simpa only [degree, ← support_toFinsupp, toFinsupp_add]
    using AddMonoidAlgebra.sup_support_add_le _ _ _

theorem degree_add_le_of_degree_le {p q : R[X]} {n : ℕ} (hp : degree p ≤ n) (hq : degree q ≤ n) :
    degree (p + q) ≤ n :=
  (degree_add_le p q).trans <| max_le hp hq

theorem degree_add_le_of_le {a b : WithBot ℕ} (hp : degree p ≤ a) (hq : degree q ≤ b) :
    degree (p + q) ≤ max a b :=
  (p.degree_add_le q).trans <| max_le_max ‹_› ‹_›

theorem natDegree_add_le (p q : R[X]) : natDegree (p + q) ≤ max (natDegree p) (natDegree q) := by
  cases' le_max_iff.1 (degree_add_le p q) with h h <;> simp [natDegree_le_natDegree h]

theorem natDegree_add_le_of_degree_le {p q : R[X]} {n : ℕ} (hp : natDegree p ≤ n)
    (hq : natDegree q ≤ n) : natDegree (p + q) ≤ n :=
  (natDegree_add_le p q).trans <| max_le hp hq

theorem natDegree_add_le_of_le (hp : natDegree p ≤ m) (hq : natDegree q ≤ n) :
    natDegree (p + q) ≤ max m n :=
  (p.natDegree_add_le q).trans <| max_le_max ‹_› ‹_›

@[simp]
theorem leadingCoeff_zero : leadingCoeff (0 : R[X]) = 0 :=
  rfl

@[simp]
theorem leadingCoeff_eq_zero : leadingCoeff p = 0 ↔ p = 0 :=
  ⟨fun h =>
    Classical.by_contradiction fun hp =>
      mt mem_support_iff.1 (Classical.not_not.2 h) (mem_of_max (degree_eq_natDegree hp)),
    fun h => h.symm ▸ leadingCoeff_zero⟩

theorem leadingCoeff_ne_zero : leadingCoeff p ≠ 0 ↔ p ≠ 0 := by rw [Ne, leadingCoeff_eq_zero]

theorem leadingCoeff_eq_zero_iff_deg_eq_bot : leadingCoeff p = 0 ↔ degree p = ⊥ := by
  rw [leadingCoeff_eq_zero, degree_eq_bot]

lemma natDegree_le_pred (hf : p.natDegree ≤ n) (hn : p.coeff n = 0) : p.natDegree ≤ n - 1 := by
  obtain _ | n := n
  · exact hf
  · refine (Nat.le_succ_iff_eq_or_le.1 hf).resolve_left fun h ↦ ?_
    rw [← Nat.succ_eq_add_one, ← h, coeff_natDegree, leadingCoeff_eq_zero] at hn
    aesop

theorem natDegree_mem_support_of_nonzero (H : p ≠ 0) : p.natDegree ∈ p.support := by
  rw [mem_support_iff]
  exact (not_congr leadingCoeff_eq_zero).mpr H

theorem natDegree_eq_support_max' (h : p ≠ 0) :
    p.natDegree = p.support.max' (nonempty_support_iff.mpr h) :=
  (le_max' _ _ <| natDegree_mem_support_of_nonzero h).antisymm <|
    max'_le _ _ _ le_natDegree_of_mem_supp

theorem natDegree_C_mul_X_pow_le (a : R) (n : ℕ) : natDegree (C a * X ^ n) ≤ n :=
  natDegree_le_iff_degree_le.2 <| degree_C_mul_X_pow_le _ _

theorem degree_add_eq_left_of_degree_lt (h : degree q < degree p) : degree (p + q) = degree p :=
  le_antisymm (max_eq_left_of_lt h ▸ degree_add_le _ _) <|
    degree_le_degree <| by
      rw [coeff_add, coeff_natDegree_eq_zero_of_degree_lt h, add_zero]
      exact mt leadingCoeff_eq_zero.1 (ne_zero_of_degree_gt h)

theorem degree_add_eq_right_of_degree_lt (h : degree p < degree q) : degree (p + q) = degree q := by
  rw [add_comm, degree_add_eq_left_of_degree_lt h]

theorem natDegree_add_eq_left_of_degree_lt (h : degree q < degree p) :
    natDegree (p + q) = natDegree p :=
  natDegree_eq_of_degree_eq (degree_add_eq_left_of_degree_lt h)

theorem natDegree_add_eq_left_of_natDegree_lt (h : natDegree q < natDegree p) :
    natDegree (p + q) = natDegree p :=
  natDegree_add_eq_left_of_degree_lt (degree_lt_degree h)

theorem natDegree_add_eq_right_of_degree_lt (h : degree p < degree q) :
    natDegree (p + q) = natDegree q :=
  natDegree_eq_of_degree_eq (degree_add_eq_right_of_degree_lt h)

theorem natDegree_add_eq_right_of_natDegree_lt (h : natDegree p < natDegree q) :
    natDegree (p + q) = natDegree q :=
  natDegree_add_eq_right_of_degree_lt (degree_lt_degree h)

theorem degree_add_C (hp : 0 < degree p) : degree (p + C a) = degree p :=
  add_comm (C a) p ▸ degree_add_eq_right_of_degree_lt <| lt_of_le_of_lt degree_C_le hp

@[simp] theorem natDegree_add_C {a : R} : (p + C a).natDegree = p.natDegree := by
  rcases eq_or_ne p 0 with rfl | hp
  · simp
  by_cases hpd : p.degree ≤ 0
  · rw [eq_C_of_degree_le_zero hpd, ← C_add, natDegree_C, natDegree_C]
  · rw [not_le, degree_eq_natDegree hp, Nat.cast_pos, ← natDegree_C a] at hpd
    exact natDegree_add_eq_left_of_natDegree_lt hpd

@[simp] theorem natDegree_C_add {a : R} : (C a + p).natDegree = p.natDegree := by
  simp [add_comm _ p]

theorem degree_add_eq_of_leadingCoeff_add_ne_zero (h : leadingCoeff p + leadingCoeff q ≠ 0) :
    degree (p + q) = max p.degree q.degree :=
  le_antisymm (degree_add_le _ _) <|
    match lt_trichotomy (degree p) (degree q) with
    | Or.inl hlt => by
      rw [degree_add_eq_right_of_degree_lt hlt, max_eq_right_of_lt hlt]
    | Or.inr (Or.inl HEq) =>
      le_of_not_gt fun hlt : max (degree p) (degree q) > degree (p + q) =>
        h <|
          show leadingCoeff p + leadingCoeff q = 0 by
            rw [HEq, max_self] at hlt
            rw [leadingCoeff, leadingCoeff, natDegree_eq_of_degree_eq HEq, ← coeff_add]
            exact coeff_natDegree_eq_zero_of_degree_lt hlt
    | Or.inr (Or.inr hlt) => by
      rw [degree_add_eq_left_of_degree_lt hlt, max_eq_left_of_lt hlt]

lemma natDegree_eq_of_natDegree_add_lt_left (p q : R[X])
    (H : natDegree (p + q) < natDegree p) : natDegree p = natDegree q := by
  by_contra h
  cases Nat.lt_or_lt_of_ne h with
  | inl h => exact lt_asymm h (by rwa [natDegree_add_eq_right_of_natDegree_lt h] at H)
  | inr h =>
    rw [natDegree_add_eq_left_of_natDegree_lt h] at H
    exact LT.lt.false H

lemma natDegree_eq_of_natDegree_add_lt_right (p q : R[X])
    (H : natDegree (p + q) < natDegree q) : natDegree p = natDegree q :=
  (natDegree_eq_of_natDegree_add_lt_left q p (add_comm p q ▸ H)).symm

lemma natDegree_eq_of_natDegree_add_eq_zero (p q : R[X])
    (H : natDegree (p + q) = 0) : natDegree p = natDegree q := by
  by_cases h₁ : natDegree p = 0; on_goal 1 => by_cases h₂ : natDegree q = 0
  · exact h₁.trans h₂.symm
  · apply natDegree_eq_of_natDegree_add_lt_right; rwa [H, Nat.pos_iff_ne_zero]
  · apply natDegree_eq_of_natDegree_add_lt_left; rwa [H, Nat.pos_iff_ne_zero]

theorem degree_erase_le (p : R[X]) (n : ℕ) : degree (p.erase n) ≤ degree p := by
  rcases p with ⟨p⟩
  simp only [erase_def, degree, coeff, support]
  -- Porting note: simpler convert-free proof to be explicit about definition unfolding
  apply sup_mono
  rw [Finsupp.support_erase]
  apply Finset.erase_subset

theorem degree_erase_lt (hp : p ≠ 0) : degree (p.erase (natDegree p)) < degree p := by
  apply lt_of_le_of_ne (degree_erase_le _ _)
  rw [degree_eq_natDegree hp, degree, support_erase]
  exact fun h => not_mem_erase _ _ (mem_of_max h)

theorem degree_update_le (p : R[X]) (n : ℕ) (a : R) : degree (p.update n a) ≤ max (degree p) n := by
  classical
  rw [degree, support_update]
  split_ifs
  · exact (Finset.max_mono (erase_subset _ _)).trans (le_max_left _ _)
  · rw [max_insert, max_comm]
    exact le_rfl

theorem degree_sum_le (s : Finset ι) (f : ι → R[X]) :
    degree (∑ i ∈ s, f i) ≤ s.sup fun b => degree (f b) :=
  Finset.cons_induction_on s (by simp only [sum_empty, sup_empty, degree_zero, le_refl])
    fun a s has ih =>
    calc
      degree (∑ i ∈ cons a s has, f i) ≤ max (degree (f a)) (degree (∑ i ∈ s, f i)) := by
        rw [Finset.sum_cons]; exact degree_add_le _ _
      _ ≤ _ := by rw [sup_cons, sup_eq_max]; exact max_le_max le_rfl ih

theorem degree_mul_le (p q : R[X]) : degree (p * q) ≤ degree p + degree q := by
  simpa only [degree, ← support_toFinsupp, toFinsupp_mul]
    using AddMonoidAlgebra.sup_support_mul_le (WithBot.coe_add _ _).le _ _

theorem degree_mul_le_of_le {a b : WithBot ℕ} (hp : degree p ≤ a) (hq : degree q ≤ b) :
    degree (p * q) ≤ a + b :=
  (p.degree_mul_le _).trans <| add_le_add ‹_› ‹_›

theorem degree_pow_le (p : R[X]) : ∀ n : ℕ, degree (p ^ n) ≤ n • degree p
  | 0 => by rw [pow_zero, zero_nsmul]; exact degree_one_le
  | n + 1 =>
    calc
      degree (p ^ (n + 1)) ≤ degree (p ^ n) + degree p := by
        rw [pow_succ]; exact degree_mul_le _ _
      _ ≤ _ := by rw [succ_nsmul]; exact add_le_add_right (degree_pow_le _ _) _

theorem degree_pow_le_of_le {a : WithBot ℕ} (b : ℕ) (hp : degree p ≤ a) :
    degree (p ^ b) ≤ b * a := by
  induction b with
  | zero => simp [degree_one_le]
  | succ n hn =>
      rw [Nat.cast_succ, add_mul, one_mul, pow_succ]
      exact degree_mul_le_of_le hn hp

@[simp]
theorem leadingCoeff_monomial (a : R) (n : ℕ) : leadingCoeff (monomial n a) = a := by
  classical
  by_cases ha : a = 0
  · simp only [ha, (monomial n).map_zero, leadingCoeff_zero]
  · rw [leadingCoeff, natDegree_monomial, if_neg ha, coeff_monomial]
    simp

theorem leadingCoeff_C_mul_X_pow (a : R) (n : ℕ) : leadingCoeff (C a * X ^ n) = a := by
  rw [C_mul_X_pow_eq_monomial, leadingCoeff_monomial]

theorem leadingCoeff_C_mul_X (a : R) : leadingCoeff (C a * X) = a := by
  simpa only [pow_one] using leadingCoeff_C_mul_X_pow a 1

@[simp]
theorem leadingCoeff_C (a : R) : leadingCoeff (C a) = a :=
  leadingCoeff_monomial a 0

theorem leadingCoeff_X_pow (n : ℕ) : leadingCoeff ((X : R[X]) ^ n) = 1 := by
  simpa only [C_1, one_mul] using leadingCoeff_C_mul_X_pow (1 : R) n

theorem leadingCoeff_X : leadingCoeff (X : R[X]) = 1 := by
  simpa only [pow_one] using @leadingCoeff_X_pow R _ 1

@[simp]
theorem monic_X_pow (n : ℕ) : Monic (X ^ n : R[X]) :=
  leadingCoeff_X_pow n

@[simp]
theorem monic_X : Monic (X : R[X]) :=
  leadingCoeff_X

theorem leadingCoeff_one : leadingCoeff (1 : R[X]) = 1 :=
  leadingCoeff_C 1

@[simp]
theorem monic_one : Monic (1 : R[X]) :=
  leadingCoeff_C _

theorem Monic.ne_zero {R : Type*} [Semiring R] [Nontrivial R] {p : R[X]} (hp : p.Monic) :
    p ≠ 0 := by
  rintro rfl
  simp [Monic] at hp

theorem Monic.ne_zero_of_ne (h : (0 : R) ≠ 1) {p : R[X]} (hp : p.Monic) : p ≠ 0 := by
  nontriviality R
  exact hp.ne_zero

theorem monic_of_natDegree_le_of_coeff_eq_one (n : ℕ) (pn : p.natDegree ≤ n) (p1 : p.coeff n = 1) :
    Monic p := by
  unfold Monic
  nontriviality
  refine (congr_arg _ <| natDegree_eq_of_le_of_coeff_ne_zero pn ?_).trans p1
  exact ne_of_eq_of_ne p1 one_ne_zero

theorem monic_of_degree_le_of_coeff_eq_one (n : ℕ) (pn : p.degree ≤ n) (p1 : p.coeff n = 1) :
    Monic p :=
  monic_of_natDegree_le_of_coeff_eq_one n (natDegree_le_of_degree_le pn) p1

theorem Monic.ne_zero_of_polynomial_ne {r} (hp : Monic p) (hne : q ≠ r) : p ≠ 0 :=
  haveI := Nontrivial.of_polynomial_ne hne
  hp.ne_zero

theorem leadingCoeff_add_of_degree_lt (h : degree p < degree q) :
    leadingCoeff (p + q) = leadingCoeff q := by
  have : coeff p (natDegree q) = 0 := coeff_natDegree_eq_zero_of_degree_lt h
  simp only [leadingCoeff, natDegree_eq_of_degree_eq (degree_add_eq_right_of_degree_lt h), this,
    coeff_add, zero_add]

theorem leadingCoeff_add_of_degree_lt' (h : degree q < degree p) :
    leadingCoeff (p + q) = leadingCoeff p := by
  rw [add_comm]
  exact leadingCoeff_add_of_degree_lt h

theorem leadingCoeff_add_of_degree_eq (h : degree p = degree q)
    (hlc : leadingCoeff p + leadingCoeff q ≠ 0) :
    leadingCoeff (p + q) = leadingCoeff p + leadingCoeff q := by
  have : natDegree (p + q) = natDegree p := by
    apply natDegree_eq_of_degree_eq
    rw [degree_add_eq_of_leadingCoeff_add_ne_zero hlc, h, max_self]
  simp only [leadingCoeff, this, natDegree_eq_of_degree_eq h, coeff_add]

@[simp]
theorem coeff_mul_degree_add_degree (p q : R[X]) :
    coeff (p * q) (natDegree p + natDegree q) = leadingCoeff p * leadingCoeff q :=
  calc
    coeff (p * q) (natDegree p + natDegree q) =
        ∑ x ∈ antidiagonal (natDegree p + natDegree q), coeff p x.1 * coeff q x.2 :=
      coeff_mul _ _ _
    _ = coeff p (natDegree p) * coeff q (natDegree q) := by
      refine Finset.sum_eq_single (natDegree p, natDegree q) ?_ ?_
      · rintro ⟨i, j⟩ h₁ h₂
        rw [mem_antidiagonal] at h₁
        by_cases H : natDegree p < i
        · rw [coeff_eq_zero_of_degree_lt
              (lt_of_le_of_lt degree_le_natDegree (WithBot.coe_lt_coe.2 H)),
            zero_mul]
        · rw [not_lt_iff_eq_or_lt] at H
          cases' H with H H
          · subst H
            rw [add_left_cancel_iff] at h₁
            dsimp at h₁
            subst h₁
            exact (h₂ rfl).elim
          · suffices natDegree q < j by
              rw [coeff_eq_zero_of_degree_lt
                  (lt_of_le_of_lt degree_le_natDegree (WithBot.coe_lt_coe.2 this)),
                mul_zero]
            by_contra! H'
            exact
              ne_of_lt (Nat.lt_of_lt_of_le (Nat.add_lt_add_right H j) (Nat.add_le_add_left H' _))
                h₁
      · intro H
        exfalso
        apply H
        rw [mem_antidiagonal]

theorem degree_mul' (h : leadingCoeff p * leadingCoeff q ≠ 0) :
    degree (p * q) = degree p + degree q :=
  have hp : p ≠ 0 := by refine mt ?_ h; exact fun hp => by rw [hp, leadingCoeff_zero, zero_mul]
  have hq : q ≠ 0 := by refine mt ?_ h; exact fun hq => by rw [hq, leadingCoeff_zero, mul_zero]
  le_antisymm (degree_mul_le _ _)
    (by
      rw [degree_eq_natDegree hp, degree_eq_natDegree hq]
      refine le_degree_of_ne_zero (n := natDegree p + natDegree q) ?_
      rwa [coeff_mul_degree_add_degree])

theorem Monic.degree_mul (hq : Monic q) : degree (p * q) = degree p + degree q :=
  letI := Classical.decEq R
  if hp : p = 0 then by simp [hp]
  else degree_mul' <| by rwa [hq.leadingCoeff, mul_one, Ne, leadingCoeff_eq_zero]

theorem natDegree_mul' (h : leadingCoeff p * leadingCoeff q ≠ 0) :
    natDegree (p * q) = natDegree p + natDegree q :=
  have hp : p ≠ 0 := mt leadingCoeff_eq_zero.2 fun h₁ => h <| by rw [h₁, zero_mul]
  have hq : q ≠ 0 := mt leadingCoeff_eq_zero.2 fun h₁ => h <| by rw [h₁, mul_zero]
  natDegree_eq_of_degree_eq_some <| by
    rw [degree_mul' h, Nat.cast_add, degree_eq_natDegree hp, degree_eq_natDegree hq]

theorem leadingCoeff_mul' (h : leadingCoeff p * leadingCoeff q ≠ 0) :
    leadingCoeff (p * q) = leadingCoeff p * leadingCoeff q := by
  unfold leadingCoeff
  rw [natDegree_mul' h, coeff_mul_degree_add_degree]
  rfl

theorem monomial_natDegree_leadingCoeff_eq_self (h : #p.support ≤ 1) :
    monomial p.natDegree p.leadingCoeff = p := by
  classical
  rcases card_support_le_one_iff_monomial.1 h with ⟨n, a, rfl⟩
  by_cases ha : a = 0 <;> simp [ha]

theorem C_mul_X_pow_eq_self (h : #p.support ≤ 1) : C p.leadingCoeff * X ^ p.natDegree = p := by
  rw [C_mul_X_pow_eq_monomial, monomial_natDegree_leadingCoeff_eq_self h]

theorem leadingCoeff_pow' : leadingCoeff p ^ n ≠ 0 → leadingCoeff (p ^ n) = leadingCoeff p ^ n :=
  Nat.recOn n (by simp) fun n ih h => by
    have h₁ : leadingCoeff p ^ n ≠ 0 := fun h₁ => h <| by rw [pow_succ, h₁, zero_mul]
    have h₂ : leadingCoeff p * leadingCoeff (p ^ n) ≠ 0 := by rwa [pow_succ', ← ih h₁] at h
    rw [pow_succ', pow_succ', leadingCoeff_mul' h₂, ih h₁]

theorem degree_pow' : ∀ {n : ℕ}, leadingCoeff p ^ n ≠ 0 → degree (p ^ n) = n • degree p
  | 0 => fun h => by rw [pow_zero, ← C_1] at *; rw [degree_C h, zero_nsmul]
  | n + 1 => fun h => by
    have h₁ : leadingCoeff p ^ n ≠ 0 := fun h₁ => h <| by rw [pow_succ, h₁, zero_mul]
    have h₂ : leadingCoeff (p ^ n) * leadingCoeff p ≠ 0 := by
      rwa [pow_succ, ← leadingCoeff_pow' h₁] at h
    rw [pow_succ, degree_mul' h₂, succ_nsmul, degree_pow' h₁]

theorem natDegree_pow' {n : ℕ} (h : leadingCoeff p ^ n ≠ 0) : natDegree (p ^ n) = n * natDegree p :=
  letI := Classical.decEq R
  if hp0 : p = 0 then
    if hn0 : n = 0 then by simp [*] else by rw [hp0, zero_pow hn0]; simp
  else
    have hpn : p ^ n ≠ 0 := fun hpn0 => by
      have h1 := h
      rw [← leadingCoeff_pow' h1, hpn0, leadingCoeff_zero] at h; exact h rfl
    Option.some_inj.1 <|
      show (natDegree (p ^ n) : WithBot ℕ) = (n * natDegree p : ℕ) by
        rw [← degree_eq_natDegree hpn, degree_pow' h, degree_eq_natDegree hp0]; simp

theorem leadingCoeff_monic_mul {p q : R[X]} (hp : Monic p) :
    leadingCoeff (p * q) = leadingCoeff q := by
  rcases eq_or_ne q 0 with (rfl | H)
  · simp
  · rw [leadingCoeff_mul', hp.leadingCoeff, one_mul]
    rwa [hp.leadingCoeff, one_mul, Ne, leadingCoeff_eq_zero]

theorem leadingCoeff_mul_monic {p q : R[X]} (hq : Monic q) :
    leadingCoeff (p * q) = leadingCoeff p :=
  letI := Classical.decEq R
  Decidable.byCases
    (fun H : leadingCoeff p = 0 => by
      rw [H, leadingCoeff_eq_zero.1 H, zero_mul, leadingCoeff_zero])
    fun H : leadingCoeff p ≠ 0 => by
      rw [leadingCoeff_mul', hq.leadingCoeff, mul_one]
      rwa [hq.leadingCoeff, mul_one]

@[simp]
theorem leadingCoeff_mul_X_pow {p : R[X]} {n : ℕ} : leadingCoeff (p * X ^ n) = leadingCoeff p :=
  leadingCoeff_mul_monic (monic_X_pow n)

@[simp]
theorem leadingCoeff_mul_X {p : R[X]} : leadingCoeff (p * X) = leadingCoeff p :=
  leadingCoeff_mul_monic monic_X

theorem natDegree_mul_le {p q : R[X]} : natDegree (p * q) ≤ natDegree p + natDegree q := by
  apply natDegree_le_of_degree_le
  apply le_trans (degree_mul_le p q)
  rw [Nat.cast_add]
  apply add_le_add <;> apply degree_le_natDegree

theorem natDegree_mul_le_of_le (hp : natDegree p ≤ m) (hg : natDegree q ≤ n) :
    natDegree (p * q) ≤ m + n :=
natDegree_mul_le.trans <| add_le_add ‹_› ‹_›

theorem natDegree_pow_le {p : R[X]} {n : ℕ} : (p ^ n).natDegree ≤ n * p.natDegree := by
  induction n with
  | zero => simp
  | succ i hi =>
    rw [pow_succ, Nat.succ_mul]
    apply le_trans natDegree_mul_le (add_le_add_right hi _)

theorem natDegree_pow_le_of_le (n : ℕ) (hp : natDegree p ≤ m) :
    natDegree (p ^ n) ≤ n * m :=
  natDegree_pow_le.trans (Nat.mul_le_mul le_rfl ‹_›)

@[simp]
theorem coeff_pow_mul_natDegree (p : R[X]) (n : ℕ) :
    (p ^ n).coeff (n * p.natDegree) = p.leadingCoeff ^ n := by
  induction n with
  | zero => simp
  | succ i hi =>
    rw [pow_succ, pow_succ, Nat.succ_mul]
    by_cases hp1 : p.leadingCoeff ^ i = 0
    · rw [hp1, zero_mul]
      by_cases hp2 : p ^ i = 0
      · rw [hp2, zero_mul, coeff_zero]
      · apply coeff_eq_zero_of_natDegree_lt
        have h1 : (p ^ i).natDegree < i * p.natDegree := by
          refine lt_of_le_of_ne natDegree_pow_le fun h => hp2 ?_
          rw [← h, hp1] at hi
          exact leadingCoeff_eq_zero.mp hi
        calc
          (p ^ i * p).natDegree ≤ (p ^ i).natDegree + p.natDegree := natDegree_mul_le
          _ < i * p.natDegree + p.natDegree := add_lt_add_right h1 _

    · rw [← natDegree_pow' hp1, ← leadingCoeff_pow' hp1]
      exact coeff_mul_degree_add_degree _ _

theorem coeff_mul_add_eq_of_natDegree_le {df dg : ℕ} {f g : R[X]}
    (hdf : natDegree f ≤ df) (hdg : natDegree g ≤ dg) :
    (f * g).coeff (df + dg) = f.coeff df * g.coeff dg := by
  rw [coeff_mul, Finset.sum_eq_single_of_mem (df, dg)]
  · rw [mem_antidiagonal]
  rintro ⟨df', dg'⟩ hmem hne
  obtain h | hdf' := lt_or_le df df'
  · rw [coeff_eq_zero_of_natDegree_lt (hdf.trans_lt h), zero_mul]
  obtain h | hdg' := lt_or_le dg dg'
  · rw [coeff_eq_zero_of_natDegree_lt (hdg.trans_lt h), mul_zero]
  obtain ⟨rfl, rfl⟩ :=
    (add_eq_add_iff_eq_and_eq hdf' hdg').mp (mem_antidiagonal.1 hmem)
  exact (hne rfl).elim

theorem zero_le_degree_iff : 0 ≤ degree p ↔ p ≠ 0 := by
  rw [← not_lt, Nat.WithBot.lt_zero_iff, degree_eq_bot]

theorem natDegree_eq_zero_iff_degree_le_zero : p.natDegree = 0 ↔ p.degree ≤ 0 := by
  rw [← nonpos_iff_eq_zero, natDegree_le_iff_degree_le, Nat.cast_zero]

theorem degree_zero_le : degree (0 : R[X]) ≤ 0 := natDegree_eq_zero_iff_degree_le_zero.mp rfl

theorem degree_le_iff_coeff_zero (f : R[X]) (n : WithBot ℕ) :
    degree f ≤ n ↔ ∀ m : ℕ, n < m → coeff f m = 0 := by
  -- Porting note: `Nat.cast_withBot` is required.
  simp only [degree, Finset.max, Finset.sup_le_iff, mem_support_iff, Ne, ← not_le,
    not_imp_comm, Nat.cast_withBot]

theorem degree_lt_iff_coeff_zero (f : R[X]) (n : ℕ) :
    degree f < n ↔ ∀ m : ℕ, n ≤ m → coeff f m = 0 := by
  simp only [degree, Finset.sup_lt_iff (WithBot.bot_lt_coe n), mem_support_iff,
    WithBot.coe_lt_coe, ← @not_le ℕ, max_eq_sup_coe, Nat.cast_withBot, Ne, not_imp_not]

theorem degree_smul_le (a : R) (p : R[X]) : degree (a • p) ≤ degree p := by
  refine (degree_le_iff_coeff_zero _ _).2 fun m hm => ?_
  rw [degree_lt_iff_coeff_zero] at hm
  simp [hm m le_rfl]

theorem natDegree_smul_le (a : R) (p : R[X]) : natDegree (a • p) ≤ natDegree p :=
  natDegree_le_natDegree (degree_smul_le a p)

theorem degree_lt_degree_mul_X (hp : p ≠ 0) : p.degree < (p * X).degree := by
  haveI := Nontrivial.of_polynomial_ne hp
  have : leadingCoeff p * leadingCoeff X ≠ 0 := by simpa
  erw [degree_mul' this, degree_eq_natDegree hp, degree_X, ← WithBot.coe_one,
    ← WithBot.coe_add, WithBot.coe_lt_coe]; exact Nat.lt_succ_self _

theorem natDegree_pos_iff_degree_pos : 0 < natDegree p ↔ 0 < degree p :=
  lt_iff_lt_of_le_iff_le natDegree_le_iff_degree_le

theorem eq_C_of_natDegree_le_zero (h : natDegree p ≤ 0) : p = C (coeff p 0) :=
  eq_C_of_degree_le_zero <| degree_le_of_natDegree_le h

theorem eq_C_of_natDegree_eq_zero (h : natDegree p = 0) : p = C (coeff p 0) :=
  eq_C_of_natDegree_le_zero h.le

lemma natDegree_eq_zero {p : R[X]} : p.natDegree = 0 ↔ ∃ x, C x = p :=
  ⟨fun h ↦ ⟨_, (eq_C_of_natDegree_eq_zero h).symm⟩, by aesop⟩

theorem eq_C_coeff_zero_iff_natDegree_eq_zero : p = C (p.coeff 0) ↔ p.natDegree = 0 :=
  ⟨fun h ↦ by rw [h, natDegree_C], eq_C_of_natDegree_eq_zero⟩

theorem eq_one_of_monic_natDegree_zero (hf : p.Monic) (hfd : p.natDegree = 0) : p = 1 := by
  rw [Monic.def, leadingCoeff, hfd] at hf
  rw [eq_C_of_natDegree_eq_zero hfd, hf, map_one]

theorem Monic.natDegree_eq_zero (hf : p.Monic) : p.natDegree = 0 ↔ p = 1 :=
  ⟨eq_one_of_monic_natDegree_zero hf, by rintro rfl; simp⟩

theorem ne_zero_of_coe_le_degree (hdeg : ↑n ≤ p.degree) : p ≠ 0 :=
  zero_le_degree_iff.mp <| (WithBot.coe_le_coe.mpr n.zero_le).trans hdeg

theorem le_natDegree_of_coe_le_degree (hdeg : ↑n ≤ p.degree) : n ≤ p.natDegree :=
  -- Porting note: `.. ▸ ..` → `rwa [..] at ..`
  WithBot.coe_le_coe.mp <| by
    rwa [degree_eq_natDegree <| ne_zero_of_coe_le_degree hdeg] at hdeg

theorem degree_sum_fin_lt {n : ℕ} (f : Fin n → R) :
    degree (∑ i : Fin n, C (f i) * X ^ (i : ℕ)) < n :=
  (degree_sum_le _ _).trans_lt <|
    (Finset.sup_lt_iff <| WithBot.bot_lt_coe n).2 fun k _hk =>
      (degree_C_mul_X_pow_le _ _).trans_lt <| WithBot.coe_lt_coe.2 k.is_lt

theorem degree_linear_le : degree (C a * X + C b) ≤ 1 :=
  degree_add_le_of_degree_le (degree_C_mul_X_le _) <| le_trans degree_C_le Nat.WithBot.coe_nonneg

theorem degree_linear_lt : degree (C a * X + C b) < 2 :=
  degree_linear_le.trans_lt <| WithBot.coe_lt_coe.mpr one_lt_two

theorem degree_C_lt_degree_C_mul_X (ha : a ≠ 0) : degree (C b) < degree (C a * X) := by
  simpa only [degree_C_mul_X ha] using degree_C_lt

@[simp]
theorem degree_linear (ha : a ≠ 0) : degree (C a * X + C b) = 1 := by
  rw [degree_add_eq_left_of_degree_lt <| degree_C_lt_degree_C_mul_X ha, degree_C_mul_X ha]

theorem natDegree_linear_le : natDegree (C a * X + C b) ≤ 1 :=
  natDegree_le_of_degree_le degree_linear_le

theorem natDegree_linear (ha : a ≠ 0) : natDegree (C a * X + C b) = 1 := by
  rw [natDegree_add_C, natDegree_C_mul_X a ha]

@[simp]
theorem leadingCoeff_linear (ha : a ≠ 0) : leadingCoeff (C a * X + C b) = a := by
  rw [add_comm, leadingCoeff_add_of_degree_lt (degree_C_lt_degree_C_mul_X ha),
    leadingCoeff_C_mul_X]

theorem degree_quadratic_le : degree (C a * X ^ 2 + C b * X + C c) ≤ 2 := by
  simpa only [add_assoc] using
    degree_add_le_of_degree_le (degree_C_mul_X_pow_le 2 a)
      (le_trans degree_linear_le <| WithBot.coe_le_coe.mpr one_le_two)

theorem degree_quadratic_lt : degree (C a * X ^ 2 + C b * X + C c) < 3 :=
  degree_quadratic_le.trans_lt <| WithBot.coe_lt_coe.mpr <| lt_add_one 2

theorem degree_linear_lt_degree_C_mul_X_sq (ha : a ≠ 0) :
    degree (C b * X + C c) < degree (C a * X ^ 2) := by
  simpa only [degree_C_mul_X_pow 2 ha] using degree_linear_lt

@[simp]
theorem degree_quadratic (ha : a ≠ 0) : degree (C a * X ^ 2 + C b * X + C c) = 2 := by
  rw [add_assoc, degree_add_eq_left_of_degree_lt <| degree_linear_lt_degree_C_mul_X_sq ha,
    degree_C_mul_X_pow 2 ha]
  rfl

theorem natDegree_quadratic_le : natDegree (C a * X ^ 2 + C b * X + C c) ≤ 2 :=
  natDegree_le_of_degree_le degree_quadratic_le

theorem natDegree_quadratic (ha : a ≠ 0) : natDegree (C a * X ^ 2 + C b * X + C c) = 2 :=
  natDegree_eq_of_degree_eq_some <| degree_quadratic ha

@[simp]
theorem leadingCoeff_quadratic (ha : a ≠ 0) : leadingCoeff (C a * X ^ 2 + C b * X + C c) = a := by
  rw [add_assoc, add_comm, leadingCoeff_add_of_degree_lt <| degree_linear_lt_degree_C_mul_X_sq ha,
    leadingCoeff_C_mul_X_pow]

theorem degree_cubic_le : degree (C a * X ^ 3 + C b * X ^ 2 + C c * X + C d) ≤ 3 := by
  simpa only [add_assoc] using
    degree_add_le_of_degree_le (degree_C_mul_X_pow_le 3 a)
      (le_trans degree_quadratic_le <| WithBot.coe_le_coe.mpr <| Nat.le_succ 2)

theorem degree_cubic_lt : degree (C a * X ^ 3 + C b * X ^ 2 + C c * X + C d) < 4 :=
  degree_cubic_le.trans_lt <| WithBot.coe_lt_coe.mpr <| lt_add_one 3

theorem degree_quadratic_lt_degree_C_mul_X_cb (ha : a ≠ 0) :
    degree (C b * X ^ 2 + C c * X + C d) < degree (C a * X ^ 3) := by
  simpa only [degree_C_mul_X_pow 3 ha] using degree_quadratic_lt

@[simp]
theorem degree_cubic (ha : a ≠ 0) : degree (C a * X ^ 3 + C b * X ^ 2 + C c * X + C d) = 3 := by
  rw [add_assoc, add_assoc, ← add_assoc (C b * X ^ 2),
    degree_add_eq_left_of_degree_lt <| degree_quadratic_lt_degree_C_mul_X_cb ha,
    degree_C_mul_X_pow 3 ha]
  rfl

theorem natDegree_cubic_le : natDegree (C a * X ^ 3 + C b * X ^ 2 + C c * X + C d) ≤ 3 :=
  natDegree_le_of_degree_le degree_cubic_le

theorem natDegree_cubic (ha : a ≠ 0) : natDegree (C a * X ^ 3 + C b * X ^ 2 + C c * X + C d) = 3 :=
  natDegree_eq_of_degree_eq_some <| degree_cubic ha

@[simp]
theorem leadingCoeff_cubic (ha : a ≠ 0) :
    leadingCoeff (C a * X ^ 3 + C b * X ^ 2 + C c * X + C d) = a := by
  rw [add_assoc, add_assoc, ← add_assoc (C b * X ^ 2), add_comm,
    leadingCoeff_add_of_degree_lt <| degree_quadratic_lt_degree_C_mul_X_cb ha,
    leadingCoeff_C_mul_X_pow]

end Semiring

section NontrivialSemiring

variable [Semiring R] [Nontrivial R] {p q : R[X]} (n : ℕ)

@[simp]
theorem degree_X_pow : degree ((X : R[X]) ^ n) = n := by
  rw [X_pow_eq_monomial, degree_monomial _ (one_ne_zero' R)]

@[simp]
theorem natDegree_X_pow : natDegree ((X : R[X]) ^ n) = n :=
  natDegree_eq_of_degree_eq_some (degree_X_pow n)

@[simp] lemma natDegree_mul_X (hp : p ≠ 0) : natDegree (p * X) = natDegree p + 1 := by
  rw [natDegree_mul' (by simpa), natDegree_X]

@[simp] lemma natDegree_X_mul (hp : p ≠ 0) : natDegree (X * p) = natDegree p + 1 := by
  rw [commute_X p, natDegree_mul_X hp]

@[simp] lemma natDegree_mul_X_pow (hp : p ≠ 0) : natDegree (p * X ^ n) = natDegree p + n := by
  rw [natDegree_mul' (by simpa), natDegree_X_pow]

@[simp] lemma natDegree_X_pow_mul (hp : p ≠ 0) : natDegree (X ^ n * p) = natDegree p + n := by
  rw [commute_X_pow, natDegree_mul_X_pow n hp]

--  This lemma explicitly does not require the `Nontrivial R` assumption.
theorem natDegree_X_pow_le {R : Type*} [Semiring R] (n : ℕ) : (X ^ n : R[X]).natDegree ≤ n := by
  nontriviality R
  rw [Polynomial.natDegree_X_pow]

theorem not_isUnit_X : ¬IsUnit (X : R[X]) := fun ⟨⟨_, g, _hfg, hgf⟩, rfl⟩ =>
  zero_ne_one' R <| by
    rw [← coeff_one_zero, ← hgf]
    simp

@[simp]
theorem degree_mul_X : degree (p * X) = degree p + 1 := by simp [monic_X.degree_mul]

@[simp]
theorem degree_mul_X_pow : degree (p * X ^ n) = degree p + n := by simp [(monic_X_pow n).degree_mul]

end NontrivialSemiring

section Ring

variable [Ring R] {p q : R[X]}

theorem degree_sub_C (hp : 0 < degree p) : degree (p - C a) = degree p := by
  rw [sub_eq_add_neg, ← C_neg, degree_add_C hp]

@[simp]
theorem natDegree_sub_C {a : R} : natDegree (p - C a) = natDegree p := by
  rw [sub_eq_add_neg, ← C_neg, natDegree_add_C]

theorem degree_sub_le (p q : R[X]) : degree (p - q) ≤ max (degree p) (degree q) := by
  simpa only [degree_neg q] using degree_add_le p (-q)

theorem degree_sub_le_of_le {a b : WithBot ℕ} (hp : degree p ≤ a) (hq : degree q ≤ b) :
    degree (p - q) ≤ max a b :=
  (p.degree_sub_le q).trans <| max_le_max ‹_› ‹_›

theorem leadingCoeff_sub_of_degree_lt (h : Polynomial.degree q < Polynomial.degree p) :
    (p - q).leadingCoeff = p.leadingCoeff := by
  rw [← q.degree_neg] at h
  rw [sub_eq_add_neg, leadingCoeff_add_of_degree_lt' h]

theorem leadingCoeff_sub_of_degree_lt' (h : Polynomial.degree p < Polynomial.degree q) :
    (p - q).leadingCoeff = -q.leadingCoeff := by
  rw [← q.degree_neg] at h
  rw [sub_eq_add_neg, leadingCoeff_add_of_degree_lt h, leadingCoeff_neg]

theorem leadingCoeff_sub_of_degree_eq (h : degree p = degree q)
    (hlc : leadingCoeff p ≠ leadingCoeff q) :
    leadingCoeff (p - q) = leadingCoeff p - leadingCoeff q := by
  replace h : degree p = degree (-q) := by rwa [q.degree_neg]
  replace hlc : leadingCoeff p + leadingCoeff (-q) ≠ 0 := by
    rwa [← sub_ne_zero, sub_eq_add_neg, ← q.leadingCoeff_neg] at hlc
  rw [sub_eq_add_neg, leadingCoeff_add_of_degree_eq h hlc, leadingCoeff_neg, sub_eq_add_neg]

theorem natDegree_sub_le (p q : R[X]) : natDegree (p - q) ≤ max (natDegree p) (natDegree q) := by
  simpa only [← natDegree_neg q] using natDegree_add_le p (-q)

theorem natDegree_sub_le_of_le (hp : natDegree p ≤ m) (hq : natDegree q ≤ n) :
    natDegree (p - q) ≤ max m n :=
  (p.natDegree_sub_le q).trans <| max_le_max ‹_› ‹_›

theorem degree_sub_lt (hd : degree p = degree q) (hp0 : p ≠ 0)
    (hlc : leadingCoeff p = leadingCoeff q) : degree (p - q) < degree p :=
  have hp : monomial (natDegree p) (leadingCoeff p) + p.erase (natDegree p) = p :=
    monomial_add_erase _ _
  have hq : monomial (natDegree q) (leadingCoeff q) + q.erase (natDegree q) = q :=
    monomial_add_erase _ _
  have hd' : natDegree p = natDegree q := by unfold natDegree; rw [hd]
  have hq0 : q ≠ 0 := mt degree_eq_bot.2 (hd ▸ mt degree_eq_bot.1 hp0)
  calc
    degree (p - q) = degree (erase (natDegree q) p + -erase (natDegree q) q) := by
      conv =>
        lhs
        rw [← hp, ← hq, hlc, hd', add_sub_add_left_eq_sub, sub_eq_add_neg]
    _ ≤ max (degree (erase (natDegree q) p)) (degree (erase (natDegree q) q)) :=
      (degree_neg (erase (natDegree q) q) ▸ degree_add_le _ _)
    _ < degree p := max_lt_iff.2 ⟨hd' ▸ degree_erase_lt hp0, hd.symm ▸ degree_erase_lt hq0⟩

theorem degree_X_sub_C_le (r : R) : (X - C r).degree ≤ 1 :=
  (degree_sub_le _ _).trans (max_le degree_X_le (degree_C_le.trans zero_le_one))

theorem natDegree_X_sub_C_le (r : R) : (X - C r).natDegree ≤ 1 :=
  natDegree_le_iff_degree_le.2 <| degree_X_sub_C_le r

theorem degree_sub_eq_left_of_degree_lt (h : degree q < degree p) : degree (p - q) = degree p := by
  rw [← degree_neg q] at h
  rw [sub_eq_add_neg, degree_add_eq_left_of_degree_lt h]

theorem degree_sub_eq_right_of_degree_lt (h : degree p < degree q) : degree (p - q) = degree q := by
  rw [← degree_neg q] at h
  rw [sub_eq_add_neg, degree_add_eq_right_of_degree_lt h, degree_neg]

theorem natDegree_sub_eq_left_of_natDegree_lt (h : natDegree q < natDegree p) :
    natDegree (p - q) = natDegree p :=
  natDegree_eq_of_degree_eq (degree_sub_eq_left_of_degree_lt (degree_lt_degree h))

theorem natDegree_sub_eq_right_of_natDegree_lt (h : natDegree p < natDegree q) :
    natDegree (p - q) = natDegree q :=
  natDegree_eq_of_degree_eq (degree_sub_eq_right_of_degree_lt (degree_lt_degree h))

end Ring

section NonzeroRing

variable [Nontrivial R]

section Semiring

variable [Semiring R]

@[simp]
theorem degree_X_add_C (a : R) : degree (X + C a) = 1 := by
  have : degree (C a) < degree (X : R[X]) :=
    calc
      degree (C a) ≤ 0 := degree_C_le
      _ < 1 := WithBot.coe_lt_coe.mpr zero_lt_one
      _ = degree X := degree_X.symm
  rw [degree_add_eq_left_of_degree_lt this, degree_X]

theorem natDegree_X_add_C (x : R) : (X + C x).natDegree = 1 :=
  natDegree_eq_of_degree_eq_some <| degree_X_add_C x

@[simp]
theorem nextCoeff_X_add_C [Semiring S] (c : S) : nextCoeff (X + C c) = c := by
  nontriviality S
  simp [nextCoeff_of_natDegree_pos]

theorem degree_X_pow_add_C {n : ℕ} (hn : 0 < n) (a : R) : degree ((X : R[X]) ^ n + C a) = n := by
  have : degree (C a) < degree ((X : R[X]) ^ n) := degree_C_le.trans_lt <| by
    rwa [degree_X_pow, Nat.cast_pos]
  rw [degree_add_eq_left_of_degree_lt this, degree_X_pow]

theorem X_pow_add_C_ne_zero {n : ℕ} (hn : 0 < n) (a : R) : (X : R[X]) ^ n + C a ≠ 0 :=
  mt degree_eq_bot.2
    (show degree ((X : R[X]) ^ n + C a) ≠ ⊥ by
      rw [degree_X_pow_add_C hn a]; exact WithBot.coe_ne_bot)

theorem X_add_C_ne_zero (r : R) : X + C r ≠ 0 :=
  pow_one (X : R[X]) ▸ X_pow_add_C_ne_zero zero_lt_one r

theorem zero_nmem_multiset_map_X_add_C {α : Type*} (m : Multiset α) (f : α → R) :
    (0 : R[X]) ∉ m.map fun a => X + C (f a) := fun mem =>
  let ⟨_a, _, ha⟩ := Multiset.mem_map.mp mem
  X_add_C_ne_zero _ ha

theorem natDegree_X_pow_add_C {n : ℕ} {r : R} : (X ^ n + C r).natDegree = n := by
  by_cases hn : n = 0
  · rw [hn, pow_zero, ← C_1, ← RingHom.map_add, natDegree_C]
  · exact natDegree_eq_of_degree_eq_some (degree_X_pow_add_C (pos_iff_ne_zero.mpr hn) r)

theorem X_pow_add_C_ne_one {n : ℕ} (hn : 0 < n) (a : R) : (X : R[X]) ^ n + C a ≠ 1 := fun h =>
  hn.ne' <| by simpa only [natDegree_X_pow_add_C, natDegree_one] using congr_arg natDegree h

theorem X_add_C_ne_one (r : R) : X + C r ≠ 1 :=
  pow_one (X : R[X]) ▸ X_pow_add_C_ne_one zero_lt_one r

end Semiring

end NonzeroRing

section Semiring

variable [Semiring R]

@[simp]
theorem leadingCoeff_X_pow_add_C {n : ℕ} (hn : 0 < n) {r : R} :
    (X ^ n + C r).leadingCoeff = 1 := by
  nontriviality R
  rw [leadingCoeff, natDegree_X_pow_add_C, coeff_add, coeff_X_pow_self, coeff_C,
    if_neg (pos_iff_ne_zero.mp hn), add_zero]

@[simp]
theorem leadingCoeff_X_add_C [Semiring S] (r : S) : (X + C r).leadingCoeff = 1 := by
  rw [← pow_one (X : S[X]), leadingCoeff_X_pow_add_C zero_lt_one]

@[simp]
theorem leadingCoeff_X_pow_add_one {n : ℕ} (hn : 0 < n) : (X ^ n + 1 : R[X]).leadingCoeff = 1 :=
  leadingCoeff_X_pow_add_C hn

@[simp]
theorem leadingCoeff_pow_X_add_C (r : R) (i : ℕ) : leadingCoeff ((X + C r) ^ i) = 1 := by
  nontriviality
  rw [leadingCoeff_pow'] <;> simp

variable [NoZeroDivisors R] {p q : R[X]}

@[simp]
lemma degree_mul : degree (p * q) = degree p + degree q :=
  letI := Classical.decEq R
  if hp0 : p = 0 then by simp only [hp0, degree_zero, zero_mul, WithBot.bot_add]
  else
    if hq0 : q = 0 then by simp only [hq0, degree_zero, mul_zero, WithBot.add_bot]
    else degree_mul' <| mul_ne_zero (mt leadingCoeff_eq_zero.1 hp0) (mt leadingCoeff_eq_zero.1 hq0)

/-- `degree` as a monoid homomorphism between `R[X]` and `Multiplicative (WithBot ℕ)`.
  This is useful to prove results about multiplication and degree. -/
def degreeMonoidHom [Nontrivial R] : R[X] →* Multiplicative (WithBot ℕ) where
  toFun := degree
  map_one' := degree_one
  map_mul' _ _ := degree_mul

@[simp]
lemma degree_pow [Nontrivial R] (p : R[X]) (n : ℕ) : degree (p ^ n) = n • degree p :=
  map_pow (@degreeMonoidHom R _ _ _) _ _

@[simp]
lemma leadingCoeff_mul (p q : R[X]) : leadingCoeff (p * q) = leadingCoeff p * leadingCoeff q := by
  by_cases hp : p = 0
  · simp only [hp, zero_mul, leadingCoeff_zero]
  · by_cases hq : q = 0
    · simp only [hq, mul_zero, leadingCoeff_zero]
    · rw [leadingCoeff_mul']
      exact mul_ne_zero (mt leadingCoeff_eq_zero.1 hp) (mt leadingCoeff_eq_zero.1 hq)

/-- `Polynomial.leadingCoeff` bundled as a `MonoidHom` when `R` has `NoZeroDivisors`, and thus
  `leadingCoeff` is multiplicative -/
def leadingCoeffHom : R[X] →* R where
  toFun := leadingCoeff
  map_one' := by simp
  map_mul' := leadingCoeff_mul

@[simp]
lemma leadingCoeffHom_apply (p : R[X]) : leadingCoeffHom p = leadingCoeff p :=
  rfl

@[simp]
lemma leadingCoeff_pow (p : R[X]) (n : ℕ) : leadingCoeff (p ^ n) = leadingCoeff p ^ n :=
  (leadingCoeffHom : R[X] →* R).map_pow p n

lemma leadingCoeff_dvd_leadingCoeff {a p : R[X]} (hap : a ∣ p) :
    a.leadingCoeff ∣ p.leadingCoeff :=
  map_dvd leadingCoeffHom hap

instance : NoZeroDivisors R[X] where
  eq_zero_or_eq_zero_of_mul_eq_zero h := by
    rw [← leadingCoeff_eq_zero, ← leadingCoeff_eq_zero]
    refine eq_zero_or_eq_zero_of_mul_eq_zero ?_
    rw [← leadingCoeff_zero, ← leadingCoeff_mul, h]
lemma natDegree_mul (hp : p ≠ 0) (hq : q ≠ 0) : (p*q).natDegree = p.natDegree + q.natDegree := by
  rw [← Nat.cast_inj (R := WithBot ℕ), ← degree_eq_natDegree (mul_ne_zero hp hq),
    Nat.cast_add, ← degree_eq_natDegree hp, ← degree_eq_natDegree hq, degree_mul]

@[simp]
lemma natDegree_pow (p : R[X]) (n : ℕ) : natDegree (p ^ n) = n * natDegree p := by
  classical
  obtain rfl | hp := eq_or_ne p 0
  · obtain rfl | hn := eq_or_ne n 0 <;> simp [*]
  exact natDegree_pow' <| by
    rw [← leadingCoeff_pow, Ne, leadingCoeff_eq_zero]; exact pow_ne_zero _ hp

lemma degree_le_mul_left (p : R[X]) (hq : q ≠ 0) : degree p ≤ degree (p * q) := by
  classical
  obtain rfl | hp := eq_or_ne p 0
  · simp
  · rw [degree_mul, degree_eq_natDegree hp, degree_eq_natDegree hq]
    exact WithBot.coe_le_coe.2 (Nat.le_add_right _ _)

lemma natDegree_le_of_dvd (h1 : p ∣ q) (h2 : q ≠ 0) : p.natDegree ≤ q.natDegree := by
  obtain ⟨q, rfl⟩ := h1
  rw [mul_ne_zero_iff] at h2
  rw [natDegree_mul h2.1 h2.2]; exact Nat.le_add_right _ _

lemma degree_le_of_dvd (h1 : p ∣ q) (h2 : q ≠ 0) : degree p ≤ degree q := by
  rcases h1 with ⟨q, rfl⟩; rw [mul_ne_zero_iff] at h2
  exact degree_le_mul_left p h2.2

lemma eq_zero_of_dvd_of_degree_lt (h₁ : p ∣ q) (h₂ : degree q < degree p) : q = 0 := by
  by_contra hc
  exact (lt_iff_not_ge _ _).mp h₂ (degree_le_of_dvd h₁ hc)

lemma eq_zero_of_dvd_of_natDegree_lt (h₁ : p ∣ q) (h₂ : natDegree q < natDegree p) :
    q = 0 := by
  by_contra hc
  exact (lt_iff_not_ge _ _).mp h₂ (natDegree_le_of_dvd h₁ hc)

lemma not_dvd_of_degree_lt (h0 : q ≠ 0) (hl : q.degree < p.degree) : ¬p ∣ q := by
  by_contra hcontra
  exact h0 (eq_zero_of_dvd_of_degree_lt hcontra hl)

lemma not_dvd_of_natDegree_lt (h0 : q ≠ 0) (hl : q.natDegree < p.natDegree) :
    ¬p ∣ q := by
  by_contra hcontra
  exact h0 (eq_zero_of_dvd_of_natDegree_lt hcontra hl)

/-- This lemma is useful for working with the `intDegree` of a rational function. -/
lemma natDegree_sub_eq_of_prod_eq {p₁ p₂ q₁ q₂ : R[X]} (hp₁ : p₁ ≠ 0) (hq₁ : q₁ ≠ 0)
    (hp₂ : p₂ ≠ 0) (hq₂ : q₂ ≠ 0) (h_eq : p₁ * q₂ = p₂ * q₁) :
    (p₁.natDegree : ℤ) - q₁.natDegree = (p₂.natDegree : ℤ) - q₂.natDegree := by
  rw [sub_eq_sub_iff_add_eq_add]
  norm_cast
  rw [← natDegree_mul hp₁ hq₂, ← natDegree_mul hp₂ hq₁, h_eq]

lemma natDegree_eq_zero_of_isUnit (h : IsUnit p) : natDegree p = 0 := by
  nontriviality R
  obtain ⟨q, hq⟩ := h.exists_right_inv
  have := natDegree_mul (left_ne_zero_of_mul_eq_one hq) (right_ne_zero_of_mul_eq_one hq)
  rw [hq, natDegree_one, eq_comm, add_eq_zero] at this
  exact this.1

lemma degree_eq_zero_of_isUnit [Nontrivial R] (h : IsUnit p) : degree p = 0 :=
  (natDegree_eq_zero_iff_degree_le_zero.mp <| natDegree_eq_zero_of_isUnit h).antisymm
    (zero_le_degree_iff.mpr h.ne_zero)

@[simp]
lemma degree_coe_units [Nontrivial R] (u : R[X]ˣ) : degree (u : R[X]) = 0 :=
  degree_eq_zero_of_isUnit ⟨u, rfl⟩

/-- Characterization of a unit of a polynomial ring over an integral domain `R`.
See `Polynomial.isUnit_iff_coeff_isUnit_isNilpotent` when `R` is a commutative ring. -/
lemma isUnit_iff : IsUnit p ↔ ∃ r : R, IsUnit r ∧ C r = p :=
  ⟨fun hp =>
    ⟨p.coeff 0,
      let h := eq_C_of_natDegree_eq_zero (natDegree_eq_zero_of_isUnit hp)
      ⟨isUnit_C.1 (h ▸ hp), h.symm⟩⟩,
    fun ⟨_, hr, hrp⟩ => hrp ▸ isUnit_C.2 hr⟩

lemma not_isUnit_of_degree_pos (p : R[X]) (hpl : 0 < p.degree) : ¬ IsUnit p := by
  cases subsingleton_or_nontrivial R
  · simp [Subsingleton.elim p 0] at hpl
  intro h
  simp [degree_eq_zero_of_isUnit h] at hpl

lemma not_isUnit_of_natDegree_pos (p : R[X]) (hpl : 0 < p.natDegree) : ¬ IsUnit p :=
  not_isUnit_of_degree_pos _ (natDegree_pos_iff_degree_pos.mp hpl)

@[simp] lemma natDegree_coe_units (u : R[X]ˣ) : natDegree (u : R[X]) = 0 := by
  nontriviality R
  exact natDegree_eq_of_degree_eq_some (degree_coe_units u)

theorem coeff_coe_units_zero_ne_zero [Nontrivial R] (u : R[X]ˣ) : coeff (u : R[X]) 0 ≠ 0 := by
  conv in 0 => rw [← natDegree_coe_units u]
  rw [← leadingCoeff, Ne, leadingCoeff_eq_zero]
  exact Units.ne_zero _

end Semiring

section CommSemiring
variable [CommSemiring R] {a p : R[X]} (hp : p.Monic)
include hp

lemma Monic.C_dvd_iff_isUnit {a : R} : C a ∣ p ↔ IsUnit a where
  mp h := isUnit_iff_dvd_one.mpr <| hp.coeff_natDegree ▸ (C_dvd_iff_dvd_coeff _ _).mp h p.natDegree
  mpr ha := (ha.map C).dvd

lemma Monic.natDegree_pos : 0 < natDegree p ↔ p ≠ 1 :=
  Nat.pos_iff_ne_zero.trans hp.natDegree_eq_zero.not

lemma Monic.degree_pos : 0 < degree p ↔ p ≠ 1 :=
  natDegree_pos_iff_degree_pos.symm.trans hp.natDegree_pos

lemma Monic.degree_pos_of_not_isUnit (hu : ¬IsUnit p) : 0 < degree p :=
  hp.degree_pos.mpr fun hp' ↦ (hp' ▸ hu) isUnit_one

lemma Monic.natDegree_pos_of_not_isUnit (hu : ¬IsUnit p) : 0 < natDegree p :=
  hp.natDegree_pos.mpr fun hp' ↦ (hp' ▸ hu) isUnit_one

lemma degree_pos_of_not_isUnit_of_dvd_monic (ha : ¬IsUnit a) (hap : a ∣ p) : 0 < degree a := by
  contrapose! ha with h
  rw [Polynomial.eq_C_of_degree_le_zero h] at hap ⊢
  simpa [hp.C_dvd_iff_isUnit, isUnit_C] using hap

lemma natDegree_pos_of_not_isUnit_of_dvd_monic (ha : ¬IsUnit a) (hap : a ∣ p) : 0 < natDegree a :=
  natDegree_pos_iff_degree_pos.mpr <| degree_pos_of_not_isUnit_of_dvd_monic hp ha hap

end CommSemiring

section Ring

variable [Ring R]

@[simp]
theorem leadingCoeff_X_pow_sub_C {n : ℕ} (hn : 0 < n) {r : R} :
    (X ^ n - C r).leadingCoeff = 1 := by
  rw [sub_eq_add_neg, ← map_neg C r, leadingCoeff_X_pow_add_C hn]

@[simp]
theorem leadingCoeff_X_pow_sub_one {n : ℕ} (hn : 0 < n) : (X ^ n - 1 : R[X]).leadingCoeff = 1 :=
  leadingCoeff_X_pow_sub_C hn

variable [Nontrivial R]

@[simp]
theorem degree_X_sub_C (a : R) : degree (X - C a) = 1 := by
  rw [sub_eq_add_neg, ← map_neg C a, degree_X_add_C]

theorem natDegree_X_sub_C (x : R) : (X - C x).natDegree = 1 := by
  rw [natDegree_sub_C, natDegree_X]

@[simp]
theorem nextCoeff_X_sub_C [Ring S] (c : S) : nextCoeff (X - C c) = -c := by
  rw [sub_eq_add_neg, ← map_neg C c, nextCoeff_X_add_C]

theorem degree_X_pow_sub_C {n : ℕ} (hn : 0 < n) (a : R) : degree ((X : R[X]) ^ n - C a) = n := by
  rw [sub_eq_add_neg, ← map_neg C a, degree_X_pow_add_C hn]

theorem X_pow_sub_C_ne_zero {n : ℕ} (hn : 0 < n) (a : R) : (X : R[X]) ^ n - C a ≠ 0 := by
  rw [sub_eq_add_neg, ← map_neg C a]
  exact X_pow_add_C_ne_zero hn _

theorem X_sub_C_ne_zero (r : R) : X - C r ≠ 0 :=
  pow_one (X : R[X]) ▸ X_pow_sub_C_ne_zero zero_lt_one r

theorem zero_nmem_multiset_map_X_sub_C {α : Type*} (m : Multiset α) (f : α → R) :
    (0 : R[X]) ∉ m.map fun a => X - C (f a) := fun mem =>
  let ⟨_a, _, ha⟩ := Multiset.mem_map.mp mem
  X_sub_C_ne_zero _ ha

theorem natDegree_X_pow_sub_C {n : ℕ} {r : R} : (X ^ n - C r).natDegree = n := by
  rw [sub_eq_add_neg, ← map_neg C r, natDegree_X_pow_add_C]

@[simp]
theorem leadingCoeff_X_sub_C [Ring S] (r : S) : (X - C r).leadingCoeff = 1 := by
  rw [sub_eq_add_neg, ← map_neg C r, leadingCoeff_X_add_C]

variable [IsDomain R] {p q : R[X]}

instance : IsDomain R[X] := NoZeroDivisors.to_isDomain _

end Ring
end Polynomial

set_option linter.style.longFile 1700
