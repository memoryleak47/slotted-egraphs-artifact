import Mathlib.Testing.Egg.SimpOnlyOverride
/-
Copyright (c) 2017 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Johan Commelin, Mario Carneiro
-/
import Mathlib.Algebra.Algebra.Tower
import Mathlib.Algebra.GroupWithZero.Divisibility
import Mathlib.Algebra.Regular.Pow
import Mathlib.Algebra.MonoidAlgebra.Support
import Mathlib.Data.Finsupp.Antidiagonal
import Mathlib.Order.SymmDiff
import Mathlib.RingTheory.Adjoin.Basic
import Mathlib.Algebra.MonoidAlgebra.Basic

/-!
# Multivariate polynomials

This file defines polynomial rings over a base ring (or even semiring),
with variables from a general type `σ` (which could be infinite).

## Important definitions

Let `R` be a commutative ring (or a semiring) and let `σ` be an arbitrary
type. This file creates the type `MvPolynomial σ R`, which mathematicians
might denote $R[X_i : i \in σ]$. It is the type of multivariate
(a.k.a. multivariable) polynomials, with variables
corresponding to the terms in `σ`, and coefficients in `R`.

### Notation

In the definitions below, we use the following notation:

+ `σ : Type*` (indexing the variables)
+ `R : Type*` `[CommSemiring R]` (the coefficients)
+ `s : σ →₀ ℕ`, a function from `σ` to `ℕ` which is zero away from a finite set.
  This will give rise to a monomial in `MvPolynomial σ R` which mathematicians might call `X^s`
+ `a : R`
+ `i : σ`, with corresponding monomial `X i`, often denoted `X_i` by mathematicians
+ `p : MvPolynomial σ R`

### Definitions

* `MvPolynomial σ R` : the type of polynomials with variables of type `σ` and coefficients
  in the commutative semiring `R`
* `monomial s a` : the monomial which mathematically would be denoted `a * X^s`
* `C a` : the constant polynomial with value `a`
* `X i` : the degree one monomial corresponding to i; mathematically this might be denoted `Xᵢ`.
* `coeff s p` : the coefficient of `s` in `p`.
* `eval₂ (f : R → S₁) (g : σ → S₁) p` : given a semiring homomorphism from `R` to another
  semiring `S₁`, and a map `σ → S₁`, evaluates `p` at this valuation, returning a term of type `S₁`.
  Note that `eval₂` can be made using `eval` and `map` (see below), and it has been suggested
  that sticking to `eval` and `map` might make the code less brittle.
* `eval (g : σ → R) p` : given a map `σ → R`, evaluates `p` at this valuation,
  returning a term of type `R`
* `map (f : R → S₁) p` : returns the multivariate polynomial obtained from `p` by the change of
  coefficient semiring corresponding to `f`
* `aeval (g : σ → S₁) p` : evaluates the multivariate polynomial obtained from `p` by the change
  of coefficient semiring corresponding to `g` (`a` stands for `Algebra`)

## Implementation notes

Recall that if `Y` has a zero, then `X →₀ Y` is the type of functions from `X` to `Y` with finite
support, i.e. such that only finitely many elements of `X` get sent to non-zero terms in `Y`.
The definition of `MvPolynomial σ R` is `(σ →₀ ℕ) →₀ R`; here `σ →₀ ℕ` denotes the space of all
monomials in the variables, and the function to `R` sends a monomial to its coefficient in
the polynomial being represented.

## Tags

polynomial, multivariate polynomial, multivariable polynomial

-/

noncomputable section

open Set Function Finsupp AddMonoidAlgebra
open scoped Pointwise

universe u v w x

variable {R : Type u} {S₁ : Type v} {S₂ : Type w} {S₃ : Type x}

/-- Multivariate polynomial, where `σ` is the index set of the variables and
  `R` is the coefficient ring -/
def MvPolynomial (σ : Type*) (R : Type*) [CommSemiring R] :=
  AddMonoidAlgebra R (σ →₀ ℕ)

namespace MvPolynomial

-- Porting note: because of `MvPolynomial.C` and `MvPolynomial.X` this linter throws
-- tons of warnings in this file, and it's easier to just disable them globally in the file

variable {σ : Type*} {a a' a₁ a₂ : R} {e : ℕ} {n m : σ} {s : σ →₀ ℕ}

section CommSemiring

section Instances

instance decidableEqMvPolynomial [CommSemiring R] [DecidableEq σ] [DecidableEq R] :
    DecidableEq (MvPolynomial σ R) :=
  Finsupp.instDecidableEq

instance commSemiring [CommSemiring R] : CommSemiring (MvPolynomial σ R) :=
  AddMonoidAlgebra.commSemiring

instance inhabited [CommSemiring R] : Inhabited (MvPolynomial σ R) :=
  ⟨0⟩

instance distribuMulAction [Monoid R] [CommSemiring S₁] [DistribMulAction R S₁] :
    DistribMulAction R (MvPolynomial σ S₁) :=
  AddMonoidAlgebra.distribMulAction

instance smulZeroClass [CommSemiring S₁] [SMulZeroClass R S₁] :
    SMulZeroClass R (MvPolynomial σ S₁) :=
  AddMonoidAlgebra.smulZeroClass

instance faithfulSMul [CommSemiring S₁] [SMulZeroClass R S₁] [FaithfulSMul R S₁] :
    FaithfulSMul R (MvPolynomial σ S₁) :=
  AddMonoidAlgebra.faithfulSMul

instance module [Semiring R] [CommSemiring S₁] [Module R S₁] : Module R (MvPolynomial σ S₁) :=
  AddMonoidAlgebra.module

instance isScalarTower [CommSemiring S₂] [SMul R S₁] [SMulZeroClass R S₂] [SMulZeroClass S₁ S₂]
    [IsScalarTower R S₁ S₂] : IsScalarTower R S₁ (MvPolynomial σ S₂) :=
  AddMonoidAlgebra.isScalarTower

instance smulCommClass [CommSemiring S₂] [SMulZeroClass R S₂] [SMulZeroClass S₁ S₂]
    [SMulCommClass R S₁ S₂] : SMulCommClass R S₁ (MvPolynomial σ S₂) :=
  AddMonoidAlgebra.smulCommClass

instance isCentralScalar [CommSemiring S₁] [SMulZeroClass R S₁] [SMulZeroClass Rᵐᵒᵖ S₁]
    [IsCentralScalar R S₁] : IsCentralScalar R (MvPolynomial σ S₁) :=
  AddMonoidAlgebra.isCentralScalar

instance algebra [CommSemiring R] [CommSemiring S₁] [Algebra R S₁] :
    Algebra R (MvPolynomial σ S₁) :=
  AddMonoidAlgebra.algebra

instance isScalarTower_right [CommSemiring S₁] [DistribSMul R S₁] [IsScalarTower R S₁ S₁] :
    IsScalarTower R (MvPolynomial σ S₁) (MvPolynomial σ S₁) :=
  AddMonoidAlgebra.isScalarTower_self _

instance smulCommClass_right [CommSemiring S₁] [DistribSMul R S₁] [SMulCommClass R S₁ S₁] :
    SMulCommClass R (MvPolynomial σ S₁) (MvPolynomial σ S₁) :=
  AddMonoidAlgebra.smulCommClass_self _

/-- If `R` is a subsingleton, then `MvPolynomial σ R` has a unique element -/
instance unique [CommSemiring R] [Subsingleton R] : Unique (MvPolynomial σ R) :=
  AddMonoidAlgebra.unique

end Instances

variable [CommSemiring R] [CommSemiring S₁] {p q : MvPolynomial σ R}

/-- `monomial s a` is the monomial with coefficient `a` and exponents given by `s`  -/
def monomial (s : σ →₀ ℕ) : R →ₗ[R] MvPolynomial σ R :=
  AddMonoidAlgebra.lsingle s

theorem single_eq_monomial (s : σ →₀ ℕ) (a : R) : Finsupp.single s a = monomial s a :=
  rfl

theorem mul_def : p * q = p.sum fun m a => q.sum fun n b => monomial (m + n) (a * b) :=
  AddMonoidAlgebra.mul_def

/-- `C a` is the constant polynomial with value `a` -/
def C : R →+* MvPolynomial σ R :=
  { singleZeroRingHom with toFun := monomial 0 }

variable (R σ)

@[simp]
theorem algebraMap_eq : algebraMap R (MvPolynomial σ R) = C :=
  rfl

variable {R σ}

/-- `X n` is the degree `1` monomial $X_n$. -/
def X (n : σ) : MvPolynomial σ R :=
  monomial (Finsupp.single n 1) 1

theorem monomial_left_injective {r : R} (hr : r ≠ 0) :
    Function.Injective fun s : σ →₀ ℕ => monomial s r :=
  Finsupp.single_left_injective hr

@[simp]
theorem monomial_left_inj {s t : σ →₀ ℕ} {r : R} (hr : r ≠ 0) :
    monomial s r = monomial t r ↔ s = t :=
  Finsupp.single_left_inj hr

theorem C_apply : (C a : MvPolynomial σ R) = monomial 0 a :=
  rfl

@[simp]
theorem C_0 : C 0 = (0 : MvPolynomial σ R) := map_zero _

@[simp]
theorem C_1 : C 1 = (1 : MvPolynomial σ R) :=
  rfl

theorem C_mul_monomial : C a * monomial s a' = monomial s (a * a') := by
  -- Porting note: this `show` feels like defeq abuse, but I can't find the appropriate lemmas
  show AddMonoidAlgebra.single _ _ * AddMonoidAlgebra.single _ _ = AddMonoidAlgebra.single _ _
  simp [C_apply, single_mul_single]

@[simp]
theorem C_add : (C (a + a') : MvPolynomial σ R) = C a + C a' :=
  Finsupp.single_add _ _ _

@[simp]
theorem C_mul : (C (a * a') : MvPolynomial σ R) = C a * C a' :=
  C_mul_monomial.symm

@[simp]
theorem C_pow (a : R) (n : ℕ) : (C (a ^ n) : MvPolynomial σ R) = C a ^ n :=
  map_pow _ _ _

theorem C_injective (σ : Type*) (R : Type*) [CommSemiring R] :
    Function.Injective (C : R → MvPolynomial σ R) :=
  Finsupp.single_injective _

theorem C_surjective {R : Type*} [CommSemiring R] (σ : Type*) [IsEmpty σ] :
    Function.Surjective (C : R → MvPolynomial σ R) := by
  refine fun p => ⟨p.toFun 0, Finsupp.ext fun a => ?_⟩
  simp only [C_apply, ← single_eq_monomial, (Finsupp.ext isEmptyElim (α := σ) : a = 0),
    single_eq_same]
  rfl

@[simp]
theorem C_inj {σ : Type*} (R : Type*) [CommSemiring R] (r s : R) :
    (C r : MvPolynomial σ R) = C s ↔ r = s :=
  (C_injective σ R).eq_iff

instance nontrivial_of_nontrivial (σ : Type*) (R : Type*) [CommSemiring R] [Nontrivial R] :
    Nontrivial (MvPolynomial σ R) :=
  inferInstanceAs (Nontrivial <| AddMonoidAlgebra R (σ →₀ ℕ))

instance infinite_of_infinite (σ : Type*) (R : Type*) [CommSemiring R] [Infinite R] :
    Infinite (MvPolynomial σ R) :=
  Infinite.of_injective C (C_injective _ _)

instance infinite_of_nonempty (σ : Type*) (R : Type*) [Nonempty σ] [CommSemiring R]
    [Nontrivial R] : Infinite (MvPolynomial σ R) :=
  Infinite.of_injective ((fun s : σ →₀ ℕ => monomial s 1) ∘ Finsupp.single (Classical.arbitrary σ))
    <| (monomial_left_injective one_ne_zero).comp (Finsupp.single_injective _)

theorem C_eq_coe_nat (n : ℕ) : (C ↑n : MvPolynomial σ R) = n := by
  induction n <;> simp [*]

theorem C_mul' : MvPolynomial.C a * p = a • p :=
  (Algebra.smul_def a p).symm

theorem smul_eq_C_mul (p : MvPolynomial σ R) (a : R) : a • p = C a * p :=
  C_mul'.symm

theorem C_eq_smul_one : (C a : MvPolynomial σ R) = a • (1 : MvPolynomial σ R) := by
  rw [← C_mul', mul_one]

theorem smul_monomial {S₁ : Type*} [SMulZeroClass S₁ R] (r : S₁) :
    r • monomial s a = monomial s (r • a) :=
  Finsupp.smul_single _ _ _

theorem X_injective [Nontrivial R] : Function.Injective (X : σ → MvPolynomial σ R) :=
  (monomial_left_injective one_ne_zero).comp (Finsupp.single_left_injective one_ne_zero)

@[simp]
theorem X_inj [Nontrivial R] (m n : σ) : X m = (X n : MvPolynomial σ R) ↔ m = n :=
  X_injective.eq_iff

theorem monomial_pow : monomial s a ^ e = monomial (e • s) (a ^ e) :=
  AddMonoidAlgebra.single_pow e

@[simp]
theorem monomial_mul {s s' : σ →₀ ℕ} {a b : R} :
    monomial s a * monomial s' b = monomial (s + s') (a * b) :=
  AddMonoidAlgebra.single_mul_single

variable (σ R)

/-- `fun s ↦ monomial s 1` as a homomorphism. -/
def monomialOneHom : Multiplicative (σ →₀ ℕ) →* MvPolynomial σ R :=
  AddMonoidAlgebra.of _ _

variable {σ R}

@[simp]
theorem monomialOneHom_apply : monomialOneHom R σ s = (monomial s 1 : MvPolynomial σ R) :=
  rfl

theorem X_pow_eq_monomial : X n ^ e = monomial (Finsupp.single n e) (1 : R) := by
  simp [X, monomial_pow]

theorem monomial_add_single : monomial (s + Finsupp.single n e) a = monomial s a * X n ^ e := by
  rw [X_pow_eq_monomial, monomial_mul, mul_one]

theorem monomial_single_add : monomial (Finsupp.single n e + s) a = X n ^ e * monomial s a := by
  rw [X_pow_eq_monomial, monomial_mul, one_mul]

theorem C_mul_X_pow_eq_monomial {s : σ} {a : R} {n : ℕ} :
    C a * X s ^ n = monomial (Finsupp.single s n) a := by
  rw [← zero_add (Finsupp.single s n), monomial_add_single, C_apply]

theorem C_mul_X_eq_monomial {s : σ} {a : R} : C a * X s = monomial (Finsupp.single s 1) a := by
  rw [← C_mul_X_pow_eq_monomial, pow_one]

@[simp]
theorem monomial_zero {s : σ →₀ ℕ} : monomial s (0 : R) = 0 :=
  Finsupp.single_zero _

@[simp]
theorem monomial_zero' : (monomial (0 : σ →₀ ℕ) : R → MvPolynomial σ R) = C :=
  rfl

@[simp]
theorem monomial_eq_zero {s : σ →₀ ℕ} {b : R} : monomial s b = 0 ↔ b = 0 :=
  Finsupp.single_eq_zero

@[simp]
theorem sum_monomial_eq {A : Type*} [AddCommMonoid A] {u : σ →₀ ℕ} {r : R} {b : (σ →₀ ℕ) → R → A}
    (w : b u 0 = 0) : sum (monomial u r) b = b u r :=
  Finsupp.sum_single_index w

@[simp]
theorem sum_C {A : Type*} [AddCommMonoid A] {b : (σ →₀ ℕ) → R → A} (w : b 0 0 = 0) :
    sum (C a) b = b 0 a :=
  sum_monomial_eq w

theorem monomial_sum_one {α : Type*} (s : Finset α) (f : α → σ →₀ ℕ) :
    (monomial (∑ i ∈ s, f i) 1 : MvPolynomial σ R) = ∏ i ∈ s, monomial (f i) 1 :=
  map_prod (monomialOneHom R σ) (fun i => Multiplicative.ofAdd (f i)) s

theorem monomial_sum_index {α : Type*} (s : Finset α) (f : α → σ →₀ ℕ) (a : R) :
    monomial (∑ i ∈ s, f i) a = C a * ∏ i ∈ s, monomial (f i) 1 := by
  rw [← monomial_sum_one, C_mul', ← (monomial _).map_smul, smul_eq_mul, mul_one]

theorem monomial_finsupp_sum_index {α β : Type*} [Zero β] (f : α →₀ β) (g : α → β → σ →₀ ℕ)
    (a : R) : monomial (f.sum g) a = C a * f.prod fun a b => monomial (g a b) 1 :=
  monomial_sum_index _ _ _

theorem monomial_eq_monomial_iff {α : Type*} (a₁ a₂ : α →₀ ℕ) (b₁ b₂ : R) :
    monomial a₁ b₁ = monomial a₂ b₂ ↔ a₁ = a₂ ∧ b₁ = b₂ ∨ b₁ = 0 ∧ b₂ = 0 :=
  Finsupp.single_eq_single_iff _ _ _ _

theorem monomial_eq : monomial s a = C a * (s.prod fun n e => X n ^ e : MvPolynomial σ R) := by
  simp only [X_pow_eq_monomial, ← monomial_finsupp_sum_index, Finsupp.sum_single]

@[simp]
lemma prod_X_pow_eq_monomial : ∏ x ∈ s.support, X x ^ s x = monomial s (1 : R) := by
  simp only [monomial_eq, map_one, one_mul, Finsupp.prod]

theorem induction_on_monomial {M : MvPolynomial σ R → Prop} (h_C : ∀ a, M (C a))
    (h_X : ∀ p n, M p → M (p * X n)) : ∀ s a, M (monomial s a) := by
  intro s a
  apply @Finsupp.induction σ ℕ _ _ s
  · show M (monomial 0 a)
    exact h_C a
  · intro n e p _hpn _he ih
    have : ∀ e : ℕ, M (monomial p a * X n ^ e) := by
      intro e
      induction e with
      | zero => simp [ih]
      | succ e e_ih => simp [ih, pow_succ, (mul_assoc _ _ _).symm, h_X, e_ih]
    simp [add_comm, monomial_add_single, this]

/-- Analog of `Polynomial.induction_on'`.
To prove something about mv_polynomials,
it suffices to show the condition is closed under taking sums,
and it holds for monomials. -/
@[elab_as_elim]
theorem induction_on' {P : MvPolynomial σ R → Prop} (p : MvPolynomial σ R)
    (h1 : ∀ (u : σ →₀ ℕ) (a : R), P (monomial u a))
    (h2 : ∀ p q : MvPolynomial σ R, P p → P q → P (p + q)) : P p :=
  Finsupp.induction p
    (suffices P (monomial 0 0) by rwa [monomial_zero] at this
    show P (monomial 0 0) from h1 0 0)
    fun _ _ _ _ha _hb hPf => h2 _ _ (h1 _ _) hPf

/-- Similar to `MvPolynomial.induction_on` but only a weak form of `h_add` is required. -/
theorem induction_on''' {M : MvPolynomial σ R → Prop} (p : MvPolynomial σ R) (h_C : ∀ a, M (C a))
    (h_add_weak :
      ∀ (a : σ →₀ ℕ) (b : R) (f : (σ →₀ ℕ) →₀ R),
        a ∉ f.support → b ≠ 0 → M f → M ((show (σ →₀ ℕ) →₀ R from monomial a b) + f)) :
    M p :=
    -- Porting note: I had to add the `show ... from ...` above, a type ascription was insufficient.
  Finsupp.induction p (C_0.rec <| h_C 0) h_add_weak

/-- Similar to `MvPolynomial.induction_on` but only a yet weaker form of `h_add` is required. -/
theorem induction_on'' {M : MvPolynomial σ R → Prop} (p : MvPolynomial σ R) (h_C : ∀ a, M (C a))
    (h_add_weak :
      ∀ (a : σ →₀ ℕ) (b : R) (f : (σ →₀ ℕ) →₀ R),
        a ∉ f.support → b ≠ 0 → M f → M (monomial a b) →
          M ((show (σ →₀ ℕ) →₀ R from monomial a b) + f))
    (h_X : ∀ (p : MvPolynomial σ R) (n : σ), M p → M (p * MvPolynomial.X n)) : M p :=
    -- Porting note: I had to add the `show ... from ...` above, a type ascription was insufficient.
  induction_on''' p h_C fun a b f ha hb hf =>
    h_add_weak a b f ha hb hf <| induction_on_monomial h_C h_X a b

/-- Analog of `Polynomial.induction_on`. -/
@[recursor 5]
theorem induction_on {M : MvPolynomial σ R → Prop} (p : MvPolynomial σ R) (h_C : ∀ a, M (C a))
    (h_add : ∀ p q, M p → M q → M (p + q)) (h_X : ∀ p n, M p → M (p * X n)) : M p :=
  induction_on'' p h_C (fun a b f _ha _hb hf hm => h_add (monomial a b) f hm hf) h_X

theorem ringHom_ext {A : Type*} [Semiring A] {f g : MvPolynomial σ R →+* A}
    (hC : ∀ r, f (C r) = g (C r)) (hX : ∀ i, f (X i) = g (X i)) : f = g := by
  refine AddMonoidAlgebra.ringHom_ext' ?_ ?_
  -- Porting note (#11041): this has high priority, but Lean still chooses `RingHom.ext`, why?
  -- probably because of the type synonym
  · ext x
    exact hC _
  · apply Finsupp.mulHom_ext'; intros x
    -- Porting note (#11041): `Finsupp.mulHom_ext'` needs to have increased priority
    apply MonoidHom.ext_mnat
    exact hX _

/-- See note [partially-applied ext lemmas]. -/
@[ext 1100]
theorem ringHom_ext' {A : Type*} [Semiring A] {f g : MvPolynomial σ R →+* A}
    (hC : f.comp C = g.comp C) (hX : ∀ i, f (X i) = g (X i)) : f = g :=
  ringHom_ext (RingHom.ext_iff.1 hC) hX

theorem hom_eq_hom [Semiring S₂] (f g : MvPolynomial σ R →+* S₂) (hC : f.comp C = g.comp C)
    (hX : ∀ n : σ, f (X n) = g (X n)) (p : MvPolynomial σ R) : f p = g p :=
  RingHom.congr_fun (ringHom_ext' hC hX) p

theorem is_id (f : MvPolynomial σ R →+* MvPolynomial σ R) (hC : f.comp C = C)
    (hX : ∀ n : σ, f (X n) = X n) (p : MvPolynomial σ R) : f p = p :=
  hom_eq_hom f (RingHom.id _) hC hX p

@[ext 1100]
theorem algHom_ext' {A B : Type*} [CommSemiring A] [CommSemiring B] [Algebra R A] [Algebra R B]
    {f g : MvPolynomial σ A →ₐ[R] B}
    (h₁ :
      f.comp (IsScalarTower.toAlgHom R A (MvPolynomial σ A)) =
        g.comp (IsScalarTower.toAlgHom R A (MvPolynomial σ A)))
    (h₂ : ∀ i, f (X i) = g (X i)) : f = g :=
  AlgHom.coe_ringHom_injective (MvPolynomial.ringHom_ext' (congr_arg AlgHom.toRingHom h₁) h₂)

@[ext 1200]
theorem algHom_ext {A : Type*} [Semiring A] [Algebra R A] {f g : MvPolynomial σ R →ₐ[R] A}
    (hf : ∀ i : σ, f (X i) = g (X i)) : f = g :=
  AddMonoidAlgebra.algHom_ext' (mulHom_ext' fun X : σ => MonoidHom.ext_mnat (hf X))

@[simp]
theorem algHom_C {A : Type*} [Semiring A] [Algebra R A] (f : MvPolynomial σ R →ₐ[R] A) (r : R) :
    f (C r) = algebraMap R A r :=
  f.commutes r

@[simp]
theorem adjoin_range_X : Algebra.adjoin R (range (X : σ → MvPolynomial σ R)) = ⊤ := by
  set S := Algebra.adjoin R (range (X : σ → MvPolynomial σ R))
  refine top_unique fun p hp => ?_; clear hp
  induction p using MvPolynomial.induction_on with
  | h_C => exact S.algebraMap_mem _
  | h_add p q hp hq => exact S.add_mem hp hq
  | h_X p i hp => exact S.mul_mem hp (Algebra.subset_adjoin <| mem_range_self _)

@[ext]
theorem linearMap_ext {M : Type*} [AddCommMonoid M] [Module R M] {f g : MvPolynomial σ R →ₗ[R] M}
    (h : ∀ s, f ∘ₗ monomial s = g ∘ₗ monomial s) : f = g :=
  Finsupp.lhom_ext' h

section Support

/-- The finite set of all `m : σ →₀ ℕ` such that `X^m` has a non-zero coefficient. -/
def support (p : MvPolynomial σ R) : Finset (σ →₀ ℕ) :=
  Finsupp.support p

theorem finsupp_support_eq_support (p : MvPolynomial σ R) : Finsupp.support p = p.support :=
  rfl

theorem support_monomial [h : Decidable (a = 0)] :
    (monomial s a).support = if a = 0 then ∅ else {s} := by
  rw [← Subsingleton.elim (Classical.decEq R a 0) h]
  rfl
  -- Porting note: the proof in Lean 3 wasn't fundamentally better and needed `by convert rfl`
  -- the issue is the different decidability instances in the `ite` expressions

theorem support_monomial_subset : (monomial s a).support ⊆ {s} :=
  support_single_subset

theorem support_add [DecidableEq σ] : (p + q).support ⊆ p.support ∪ q.support :=
  Finsupp.support_add

theorem support_X [Nontrivial R] : (X n : MvPolynomial σ R).support = {Finsupp.single n 1} := by
  classical rw [X, support_monomial, if_neg]; exact one_ne_zero

theorem support_X_pow [Nontrivial R] (s : σ) (n : ℕ) :
    (X s ^ n : MvPolynomial σ R).support = {Finsupp.single s n} := by
  classical
    rw [X_pow_eq_monomial, support_monomial, if_neg (one_ne_zero' R)]

@[simp]
theorem support_zero : (0 : MvPolynomial σ R).support = ∅ :=
  rfl

theorem support_smul {S₁ : Type*} [SMulZeroClass S₁ R] {a : S₁} {f : MvPolynomial σ R} :
    (a • f).support ⊆ f.support :=
  Finsupp.support_smul

theorem support_sum {α : Type*} [DecidableEq σ] {s : Finset α} {f : α → MvPolynomial σ R} :
    (∑ x ∈ s, f x).support ⊆ s.biUnion fun x => (f x).support :=
  Finsupp.support_finset_sum

end Support

section Coeff

/-- The coefficient of the monomial `m` in the multi-variable polynomial `p`. -/
def coeff (m : σ →₀ ℕ) (p : MvPolynomial σ R) : R :=
  @DFunLike.coe ((σ →₀ ℕ) →₀ R) _ _ _ p m

@[simp]
theorem mem_support_iff {p : MvPolynomial σ R} {m : σ →₀ ℕ} : m ∈ p.support ↔ p.coeff m ≠ 0 := by
  simp [support, coeff]

theorem not_mem_support_iff {p : MvPolynomial σ R} {m : σ →₀ ℕ} : m ∉ p.support ↔ p.coeff m = 0 :=
  by simp

theorem sum_def {A} [AddCommMonoid A] {p : MvPolynomial σ R} {b : (σ →₀ ℕ) → R → A} :
    p.sum b = ∑ m ∈ p.support, b m (p.coeff m) := by simp [support, Finsupp.sum, coeff]

theorem support_mul [DecidableEq σ] (p q : MvPolynomial σ R) :
    (p * q).support ⊆ p.support + q.support :=
  AddMonoidAlgebra.support_mul p q

@[ext]
theorem ext (p q : MvPolynomial σ R) : (∀ m, coeff m p = coeff m q) → p = q :=
  Finsupp.ext

@[simp]
theorem coeff_add (m : σ →₀ ℕ) (p q : MvPolynomial σ R) : coeff m (p + q) = coeff m p + coeff m q :=
  add_apply p q m

@[simp]
theorem coeff_smul {S₁ : Type*} [SMulZeroClass S₁ R] (m : σ →₀ ℕ) (C : S₁) (p : MvPolynomial σ R) :
    coeff m (C • p) = C • coeff m p :=
  smul_apply C p m

@[simp]
theorem coeff_zero (m : σ →₀ ℕ) : coeff m (0 : MvPolynomial σ R) = 0 :=
  rfl

@[simp]
theorem coeff_zero_X (i : σ) : coeff 0 (X i : MvPolynomial σ R) = 0 :=
  single_eq_of_ne fun h => by cases Finsupp.single_eq_zero.1 h

/-- `MvPolynomial.coeff m` but promoted to an `AddMonoidHom`. -/
@[simps]
def coeffAddMonoidHom (m : σ →₀ ℕ) : MvPolynomial σ R →+ R where
  toFun := coeff m
  map_zero' := coeff_zero m
  map_add' := coeff_add m

variable (R) in
/-- `MvPolynomial.coeff m` but promoted to a `LinearMap`. -/
@[simps]
def lcoeff (m : σ →₀ ℕ) : MvPolynomial σ R →ₗ[R] R where
  toFun := coeff m
  map_add' := coeff_add m
  map_smul' := coeff_smul m

theorem coeff_sum {X : Type*} (s : Finset X) (f : X → MvPolynomial σ R) (m : σ →₀ ℕ) :
    coeff m (∑ x ∈ s, f x) = ∑ x ∈ s, coeff m (f x) :=
  map_sum (@coeffAddMonoidHom R σ _ _) _ s

theorem monic_monomial_eq (m) :
    monomial m (1 : R) = (m.prod fun n e => X n ^ e : MvPolynomial σ R) := by simp [monomial_eq]

@[simp]
theorem coeff_monomial [DecidableEq σ] (m n) (a) :
    coeff m (monomial n a : MvPolynomial σ R) = if n = m then a else 0 :=
  Finsupp.single_apply

@[simp]
theorem coeff_C [DecidableEq σ] (m) (a) :
    coeff m (C a : MvPolynomial σ R) = if 0 = m then a else 0 :=
  Finsupp.single_apply

lemma eq_C_of_isEmpty [IsEmpty σ] (p : MvPolynomial σ R) :
    p = C (p.coeff 0) := by
  obtain ⟨x, rfl⟩ := C_surjective σ p
  simp

theorem coeff_one [DecidableEq σ] (m) : coeff m (1 : MvPolynomial σ R) = if 0 = m then 1 else 0 :=
  coeff_C m 1

@[simp]
theorem coeff_zero_C (a) : coeff 0 (C a : MvPolynomial σ R) = a :=
  single_eq_same

@[simp]
theorem coeff_zero_one : coeff 0 (1 : MvPolynomial σ R) = 1 :=
  coeff_zero_C 1

theorem coeff_X_pow [DecidableEq σ] (i : σ) (m) (k : ℕ) :
    coeff m (X i ^ k : MvPolynomial σ R) = if Finsupp.single i k = m then 1 else 0 := by
  have := coeff_monomial m (Finsupp.single i k) (1 : R)
  rwa [@monomial_eq _ _ (1 : R) (Finsupp.single i k) _, C_1, one_mul, Finsupp.prod_single_index]
    at this
  exact pow_zero _

theorem coeff_X' [DecidableEq σ] (i : σ) (m) :
    coeff m (X i : MvPolynomial σ R) = if Finsupp.single i 1 = m then 1 else 0 := by
  rw [← coeff_X_pow, pow_one]

@[simp]
theorem coeff_X (i : σ) : coeff (Finsupp.single i 1) (X i : MvPolynomial σ R) = 1 := by
  classical rw [coeff_X', if_pos rfl]

@[simp]
theorem coeff_C_mul (m) (a : R) (p : MvPolynomial σ R) : coeff m (C a * p) = a * coeff m p := by
  classical
  rw [mul_def, sum_C]
  · simp (config := { contextual := true }) [sum_def, coeff_sum]
  simp

theorem coeff_mul [DecidableEq σ] (p q : MvPolynomial σ R) (n : σ →₀ ℕ) :
    coeff n (p * q) = ∑ x ∈ Finset.antidiagonal n, coeff x.1 p * coeff x.2 q :=
  AddMonoidAlgebra.mul_apply_antidiagonal p q _ _ Finset.mem_antidiagonal

@[simp]
theorem coeff_mul_monomial (m) (s : σ →₀ ℕ) (r : R) (p : MvPolynomial σ R) :
    coeff (m + s) (p * monomial s r) = coeff m p * r :=
  AddMonoidAlgebra.mul_single_apply_aux p _ _ _ _ fun _a => add_left_inj _

@[simp]
theorem coeff_monomial_mul (m) (s : σ →₀ ℕ) (r : R) (p : MvPolynomial σ R) :
    coeff (s + m) (monomial s r * p) = r * coeff m p :=
  AddMonoidAlgebra.single_mul_apply_aux p _ _ _ _ fun _a => add_right_inj _

@[simp]
theorem coeff_mul_X (m) (s : σ) (p : MvPolynomial σ R) :
    coeff (m + Finsupp.single s 1) (p * X s) = coeff m p :=
  (coeff_mul_monomial _ _ _ _).trans (mul_one _)

@[simp]
theorem coeff_X_mul (m) (s : σ) (p : MvPolynomial σ R) :
    coeff (Finsupp.single s 1 + m) (X s * p) = coeff m p :=
  (coeff_monomial_mul _ _ _ _).trans (one_mul _)

lemma coeff_single_X_pow [DecidableEq σ] (s s' : σ) (n n' : ℕ) :
    (X (R := R) s ^ n).coeff (Finsupp.single s' n')
    = if s = s' ∧ n = n' ∨ n = 0 ∧ n' = 0 then 1 else 0 := by
  simp only [coeff_X_pow, single_eq_single_iff]

@[simp]
lemma coeff_single_X [DecidableEq σ] (s s' : σ) (n : ℕ) :
    (X s).coeff (R := R) (Finsupp.single s' n) = if n = 1 ∧ s = s' then 1 else 0 := by
  simpa [eq_comm, and_comm] using coeff_single_X_pow s s' 1 n

@[simp]
theorem support_mul_X (s : σ) (p : MvPolynomial σ R) :
    (p * X s).support = p.support.map (addRightEmbedding (Finsupp.single s 1)) :=
  AddMonoidAlgebra.support_mul_single p _ (by simp) _

@[simp]
theorem support_X_mul (s : σ) (p : MvPolynomial σ R) :
    (X s * p).support = p.support.map (addLeftEmbedding (Finsupp.single s 1)) :=
  AddMonoidAlgebra.support_single_mul p _ (by simp) _

@[simp]
theorem support_smul_eq {S₁ : Type*} [Semiring S₁] [Module S₁ R] [NoZeroSMulDivisors S₁ R] {a : S₁}
    (h : a ≠ 0) (p : MvPolynomial σ R) : (a • p).support = p.support :=
  Finsupp.support_smul_eq h

theorem support_sdiff_support_subset_support_add [DecidableEq σ] (p q : MvPolynomial σ R) :
    p.support \ q.support ⊆ (p + q).support := by
  intro m hm
  simp only [Classical.not_not, mem_support_iff, Finset.mem_sdiff, Ne] at hm
  simp [hm.2, hm.1]

open scoped symmDiff in
theorem support_symmDiff_support_subset_support_add [DecidableEq σ] (p q : MvPolynomial σ R) :
    p.support ∆ q.support ⊆ (p + q).support := by
  rw [symmDiff_def, Finset.sup_eq_union]
  apply Finset.union_subset
  · exact support_sdiff_support_subset_support_add p q
  · rw [add_comm]
    exact support_sdiff_support_subset_support_add q p

theorem coeff_mul_monomial' (m) (s : σ →₀ ℕ) (r : R) (p : MvPolynomial σ R) :
    coeff m (p * monomial s r) = if s ≤ m then coeff (m - s) p * r else 0 := by
  classical
  split_ifs with h
  · conv_rhs => rw [← coeff_mul_monomial _ s]
    congr with t
    rw [tsub_add_cancel_of_le h]
  · contrapose! h
    rw [← mem_support_iff] at h
    obtain ⟨j, -, rfl⟩ : ∃ j ∈ support p, j + s = m := by
      simpa [Finset.mem_add]
        using Finset.add_subset_add_left support_monomial_subset <| support_mul _ _ h
    exact le_add_left le_rfl

theorem coeff_monomial_mul' (m) (s : σ →₀ ℕ) (r : R) (p : MvPolynomial σ R) :
    coeff m (monomial s r * p) = if s ≤ m then r * coeff (m - s) p else 0 := by
  -- note that if we allow `R` to be non-commutative we will have to duplicate the proof above.
  rw [mul_comm, mul_comm r]
  exact coeff_mul_monomial' _ _ _ _

theorem coeff_mul_X' [DecidableEq σ] (m) (s : σ) (p : MvPolynomial σ R) :
    coeff m (p * X s) = if s ∈ m.support then coeff (m - Finsupp.single s 1) p else 0 := by
  refine (coeff_mul_monomial' _ _ _ _).trans ?_
  simp_rw [Finsupp.single_le_iff, Finsupp.mem_support_iff, Nat.succ_le_iff, pos_iff_ne_zero,
    mul_one]

theorem coeff_X_mul' [DecidableEq σ] (m) (s : σ) (p : MvPolynomial σ R) :
    coeff m (X s * p) = if s ∈ m.support then coeff (m - Finsupp.single s 1) p else 0 := by
  refine (coeff_monomial_mul' _ _ _ _).trans ?_
  simp_rw [Finsupp.single_le_iff, Finsupp.mem_support_iff, Nat.succ_le_iff, pos_iff_ne_zero,
    one_mul]

theorem eq_zero_iff {p : MvPolynomial σ R} : p = 0 ↔ ∀ d, coeff d p = 0 := by
  rw [MvPolynomial.ext_iff]
  simp only [coeff_zero]

theorem ne_zero_iff {p : MvPolynomial σ R} : p ≠ 0 ↔ ∃ d, coeff d p ≠ 0 := by
  rw [Ne, eq_zero_iff]
  push_neg
  rfl

@[simp]
theorem X_ne_zero [Nontrivial R] (s : σ) :
    X (R := R) s ≠ 0 := by
  rw [ne_zero_iff]
  use Finsupp.single s 1
  simp only [coeff_X, ne_eq, one_ne_zero, not_false_eq_true]

@[simp]
theorem support_eq_empty {p : MvPolynomial σ R} : p.support = ∅ ↔ p = 0 :=
  Finsupp.support_eq_empty

@[simp]
lemma support_nonempty {p : MvPolynomial σ R} : p.support.Nonempty ↔ p ≠ 0 := by
  rw [Finset.nonempty_iff_ne_empty, ne_eq, support_eq_empty]

theorem exists_coeff_ne_zero {p : MvPolynomial σ R} (h : p ≠ 0) : ∃ d, coeff d p ≠ 0 :=
  ne_zero_iff.mp h

theorem C_dvd_iff_dvd_coeff (r : R) (φ : MvPolynomial σ R) : C r ∣ φ ↔ ∀ i, r ∣ φ.coeff i := by
  constructor
  · rintro ⟨φ, rfl⟩ c
    rw [coeff_C_mul]
    apply dvd_mul_right
  · intro h
    choose C hc using h
    classical
      let c' : (σ →₀ ℕ) → R := fun i => if i ∈ φ.support then C i else 0
      let ψ : MvPolynomial σ R := ∑ i ∈ φ.support, monomial i (c' i)
      use ψ
      apply MvPolynomial.ext
      intro i
      simp only [ψ, c', coeff_C_mul, coeff_sum, coeff_monomial, Finset.sum_ite_eq']
      split_ifs with hi
      · rw [hc]
      · rw [not_mem_support_iff] at hi
        rwa [mul_zero]

@[simp] lemma isRegular_X : IsRegular (X n : MvPolynomial σ R) := by
  suffices IsLeftRegular (X n : MvPolynomial σ R) from
    ⟨this, this.right_of_commute <| Commute.all _⟩
  intro P Q (hPQ : (X n) * P = (X n) * Q)
  ext i
  rw [← coeff_X_mul i n P, hPQ, coeff_X_mul i n Q]

@[simp] lemma isRegular_X_pow (k : ℕ) : IsRegular (X n ^ k : MvPolynomial σ R) := isRegular_X.pow k

@[simp] lemma isRegular_prod_X (s : Finset σ) :
    IsRegular (∏ n ∈ s, X n : MvPolynomial σ R) :=
  IsRegular.prod fun _ _ ↦ isRegular_X

/-- The finset of nonzero coefficients of a multivariate polynomial. -/
def coeffs (p : MvPolynomial σ R) : Finset R :=
  letI := Classical.decEq R
  Finset.image p.coeff p.support

@[simp]
lemma coeffs_zero : coeffs (0 : MvPolynomial σ R) = ∅ :=
  rfl

lemma coeffs_one : coeffs (1 : MvPolynomial σ R) ⊆ {1} := by
  classical
    rw [coeffs, Finset.image_subset_iff]
    simp_all [coeff_one]

@[nontriviality]
lemma coeffs_eq_empty_of_subsingleton [Subsingleton R] (p : MvPolynomial σ R) : p.coeffs = ∅ := by
  simpa [coeffs] using Subsingleton.eq_zero p

@[simp]
lemma coeffs_one_of_nontrivial [Nontrivial R] : coeffs (1 : MvPolynomial σ R) = {1} := by
  apply Finset.Subset.antisymm coeffs_one
  simp only [coeffs, Finset.singleton_subset_iff, Finset.mem_image]
  exact ⟨0, by simp⟩

lemma mem_coeffs_iff {p : MvPolynomial σ R} {c : R} :
    c ∈ p.coeffs ↔ ∃ n ∈ p.support, c = p.coeff n := by
  simp [coeffs, eq_comm, (Finset.mem_image)]

lemma coeff_mem_coeffs {p : MvPolynomial σ R} (m : σ →₀ ℕ)
    (h : p.coeff m ≠ 0) : p.coeff m ∈ p.coeffs :=
  letI := Classical.decEq R
  Finset.mem_image_of_mem p.coeff (mem_support_iff.mpr h)

lemma zero_not_mem_coeffs (p : MvPolynomial σ R) : 0 ∉ p.coeffs := by
  intro hz
  obtain ⟨n, hnsupp, hn⟩ := mem_coeffs_iff.mp hz
  exact (mem_support_iff.mp hnsupp) hn.symm

end Coeff

section ConstantCoeff

/-- `constantCoeff p` returns the constant term of the polynomial `p`, defined as `coeff 0 p`.
This is a ring homomorphism.
-/
def constantCoeff : MvPolynomial σ R →+* R where
  toFun := coeff 0
  map_one' := by simp [AddMonoidAlgebra.one_def]
  map_mul' := by classical simp [coeff_mul, Finsupp.support_single_ne_zero]
  map_zero' := coeff_zero _
  map_add' := coeff_add _

theorem constantCoeff_eq : (constantCoeff : MvPolynomial σ R → R) = coeff 0 :=
  rfl

variable (σ)

@[simp]
theorem constantCoeff_C (r : R) : constantCoeff (C r : MvPolynomial σ R) = r := by
  classical simp [constantCoeff_eq]

variable {σ}
variable (R)

@[simp]
theorem constantCoeff_X (i : σ) : constantCoeff (X i : MvPolynomial σ R) = 0 := by
  simp [constantCoeff_eq]

variable {R}
/- porting note: increased priority because otherwise `simp` time outs when trying to simplify
the left-hand side. `simpNF` linter indicated this and it was verified. -/
@[simp 1001]
theorem constantCoeff_smul {R : Type*} [SMulZeroClass R S₁] (a : R) (f : MvPolynomial σ S₁) :
    constantCoeff (a • f) = a • constantCoeff f :=
  rfl

theorem constantCoeff_monomial [DecidableEq σ] (d : σ →₀ ℕ) (r : R) :
    constantCoeff (monomial d r) = if d = 0 then r else 0 := by
  rw [constantCoeff_eq, coeff_monomial]

variable (σ R)

@[simp]
theorem constantCoeff_comp_C : constantCoeff.comp (C : R →+* MvPolynomial σ R) = RingHom.id R := by
  ext x
  exact constantCoeff_C σ x

theorem constantCoeff_comp_algebraMap :
    constantCoeff.comp (algebraMap R (MvPolynomial σ R)) = RingHom.id R :=
  constantCoeff_comp_C _ _

end ConstantCoeff

section AsSum

@[simp]
theorem support_sum_monomial_coeff (p : MvPolynomial σ R) :
    (∑ v ∈ p.support, monomial v (coeff v p)) = p :=
  Finsupp.sum_single p

theorem as_sum (p : MvPolynomial σ R) : p = ∑ v ∈ p.support, monomial v (coeff v p) :=
  (support_sum_monomial_coeff p).symm

end AsSum

section Eval₂

variable (f : R →+* S₁) (g : σ → S₁)

/-- Evaluate a polynomial `p` given a valuation `g` of all the variables
  and a ring hom `f` from the scalar ring to the target -/
def eval₂ (p : MvPolynomial σ R) : S₁ :=
  p.sum fun s a => f a * s.prod fun n e => g n ^ e

theorem eval₂_eq (g : R →+* S₁) (X : σ → S₁) (f : MvPolynomial σ R) :
    f.eval₂ g X = ∑ d ∈ f.support, g (f.coeff d) * ∏ i ∈ d.support, X i ^ d i :=
  rfl

theorem eval₂_eq' [Fintype σ] (g : R →+* S₁) (X : σ → S₁) (f : MvPolynomial σ R) :
    f.eval₂ g X = ∑ d ∈ f.support, g (f.coeff d) * ∏ i, X i ^ d i := by
  simp only [eval₂_eq, ← Finsupp.prod_pow]
  rfl

@[simp]
theorem eval₂_zero : (0 : MvPolynomial σ R).eval₂ f g = 0 :=
  Finsupp.sum_zero_index

section

@[simp]
theorem eval₂_add : (p + q).eval₂ f g = p.eval₂ f g + q.eval₂ f g := by
  classical exact Finsupp.sum_add_index (by simp [f.map_zero]) (by simp [add_mul, f.map_add])

@[simp]
theorem eval₂_monomial : (monomial s a).eval₂ f g = f a * s.prod fun n e => g n ^ e :=
  Finsupp.sum_single_index (by simp [f.map_zero])

@[simp]
theorem eval₂_C (a) : (C a).eval₂ f g = f a := by
  rw [C_apply, eval₂_monomial, prod_zero_index, mul_one]

@[simp]
theorem eval₂_one : (1 : MvPolynomial σ R).eval₂ f g = 1 :=
  (eval₂_C _ _ _).trans f.map_one

@[simp]
theorem eval₂_X (n) : (X n).eval₂ f g = g n := by
  simp [eval₂_monomial, f.map_one, X, prod_single_index, pow_one]

theorem eval₂_mul_monomial :
    ∀ {s a}, (p * monomial s a).eval₂ f g = p.eval₂ f g * f a * s.prod fun n e => g n ^ e := by
  classical
  apply MvPolynomial.induction_on p
  · intro a' s a
    simp [C_mul_monomial, eval₂_monomial, f.map_mul]
  · intro p q ih_p ih_q
    simp [add_mul, eval₂_add, ih_p, ih_q]
  · intro p n ih s a
    exact
      calc (p * X n * monomial s a).eval₂ f g
        _ = (p * monomial (Finsupp.single n 1 + s) a).eval₂ f g := by
          rw [monomial_single_add, pow_one, mul_assoc]
        _ = (p * monomial (Finsupp.single n 1) 1).eval₂ f g * f a * s.prod fun n e => g n ^ e := by
          simp [ih, prod_single_index, prod_add_index, pow_one, pow_add, mul_assoc, mul_left_comm,
            f.map_one]

theorem eval₂_mul_C : (p * C a).eval₂ f g = p.eval₂ f g * f a :=
  (eval₂_mul_monomial _ _).trans <| by simp

@[simp]
theorem eval₂_mul : ∀ {p}, (p * q).eval₂ f g = p.eval₂ f g * q.eval₂ f g := by
  apply MvPolynomial.induction_on q
  · simp [eval₂_C, eval₂_mul_C]
  · simp (config := { contextual := true }) [mul_add, eval₂_add]
  · simp (config := { contextual := true }) [X, eval₂_monomial, eval₂_mul_monomial, ← mul_assoc]

@[simp]
theorem eval₂_pow {p : MvPolynomial σ R} : ∀ {n : ℕ}, (p ^ n).eval₂ f g = p.eval₂ f g ^ n
  | 0 => by
    rw [pow_zero, pow_zero]
    exact eval₂_one _ _
  | n + 1 => by rw [pow_add, pow_one, pow_add, pow_one, eval₂_mul, eval₂_pow]

/-- `MvPolynomial.eval₂` as a `RingHom`. -/
def eval₂Hom (f : R →+* S₁) (g : σ → S₁) : MvPolynomial σ R →+* S₁ where
  toFun := eval₂ f g
  map_one' := eval₂_one _ _
  map_mul' _ _ := eval₂_mul _ _
  map_zero' := eval₂_zero f g
  map_add' _ _ := eval₂_add _ _

@[simp]
theorem coe_eval₂Hom (f : R →+* S₁) (g : σ → S₁) : ⇑(eval₂Hom f g) = eval₂ f g :=
  rfl

theorem eval₂Hom_congr {f₁ f₂ : R →+* S₁} {g₁ g₂ : σ → S₁} {p₁ p₂ : MvPolynomial σ R} :
    f₁ = f₂ → g₁ = g₂ → p₁ = p₂ → eval₂Hom f₁ g₁ p₁ = eval₂Hom f₂ g₂ p₂ := by
  rintro rfl rfl rfl; rfl

end

@[simp]
theorem eval₂Hom_C (f : R →+* S₁) (g : σ → S₁) (r : R) : eval₂Hom f g (C r) = f r :=
  eval₂_C f g r

@[simp]
theorem eval₂Hom_X' (f : R →+* S₁) (g : σ → S₁) (i : σ) : eval₂Hom f g (X i) = g i :=
  eval₂_X f g i

@[simp]
theorem comp_eval₂Hom [CommSemiring S₂] (f : R →+* S₁) (g : σ → S₁) (φ : S₁ →+* S₂) :
    φ.comp (eval₂Hom f g) = eval₂Hom (φ.comp f) fun i => φ (g i) := by
  apply MvPolynomial.ringHom_ext
  · intro r
    rw [RingHom.comp_apply, eval₂Hom_C, eval₂Hom_C, RingHom.comp_apply]
  · intro i
    rw [RingHom.comp_apply, eval₂Hom_X', eval₂Hom_X']

theorem map_eval₂Hom [CommSemiring S₂] (f : R →+* S₁) (g : σ → S₁) (φ : S₁ →+* S₂)
    (p : MvPolynomial σ R) : φ (eval₂Hom f g p) = eval₂Hom (φ.comp f) (fun i => φ (g i)) p := by
  rw [← comp_eval₂Hom]
  rfl

theorem eval₂Hom_monomial (f : R →+* S₁) (g : σ → S₁) (d : σ →₀ ℕ) (r : R) :
    eval₂Hom f g (monomial d r) = f r * d.prod fun i k => g i ^ k := by
  simp only [monomial_eq, RingHom.map_mul, eval₂Hom_C, Finsupp.prod, map_prod,
    RingHom.map_pow, eval₂Hom_X']

section

theorem eval₂_comp_left {S₂} [CommSemiring S₂] (k : S₁ →+* S₂) (f : R →+* S₁) (g : σ → S₁) (p) :
    k (eval₂ f g p) = eval₂ (k.comp f) (k ∘ g) p := by
  apply MvPolynomial.induction_on p <;>
    simp (config := { contextual := true }) [eval₂_add, k.map_add, eval₂_mul, k.map_mul]

end

@[simp]
theorem eval₂_eta (p : MvPolynomial σ R) : eval₂ C X p = p := by
  apply MvPolynomial.induction_on p <;>
    simp (config := { contextual := true }) [eval₂_add, eval₂_mul]

theorem eval₂_congr (g₁ g₂ : σ → S₁)
    (h : ∀ {i : σ} {c : σ →₀ ℕ}, i ∈ c.support → coeff c p ≠ 0 → g₁ i = g₂ i) :
    p.eval₂ f g₁ = p.eval₂ f g₂ := by
  apply Finset.sum_congr rfl
  intro C hc; dsimp; congr 1
  apply Finset.prod_congr rfl
  intro i hi; dsimp; congr 1
  apply h hi
  rwa [Finsupp.mem_support_iff] at hc

theorem eval₂_sum (s : Finset S₂) (p : S₂ → MvPolynomial σ R) :
    eval₂ f g (∑ x ∈ s, p x) = ∑ x ∈ s, eval₂ f g (p x) :=
  map_sum (eval₂Hom f g) _ s

@[to_additive existing (attr := simp)]
theorem eval₂_prod (s : Finset S₂) (p : S₂ → MvPolynomial σ R) :
    eval₂ f g (∏ x ∈ s, p x) = ∏ x ∈ s, eval₂ f g (p x) :=
  map_prod (eval₂Hom f g) _ s

theorem eval₂_assoc (q : S₂ → MvPolynomial σ R) (p : MvPolynomial S₂ R) :
    eval₂ f (fun t => eval₂ f g (q t)) p = eval₂ f g (eval₂ C q p) := by
  show _ = eval₂Hom f g (eval₂ C q p)
  rw [eval₂_comp_left (eval₂Hom f g)]; congr with a; simp

end Eval₂

section Eval

variable {f : σ → R}

/-- Evaluate a polynomial `p` given a valuation `f` of all the variables -/
def eval (f : σ → R) : MvPolynomial σ R →+* R :=
  eval₂Hom (RingHom.id _) f

theorem eval_eq (X : σ → R) (f : MvPolynomial σ R) :
    eval X f = ∑ d ∈ f.support, f.coeff d * ∏ i ∈ d.support, X i ^ d i :=
  rfl

theorem eval_eq' [Fintype σ] (X : σ → R) (f : MvPolynomial σ R) :
    eval X f = ∑ d ∈ f.support, f.coeff d * ∏ i, X i ^ d i :=
  eval₂_eq' (RingHom.id R) X f

theorem eval_monomial : eval f (monomial s a) = a * s.prod fun n e => f n ^ e :=
  eval₂_monomial _ _

@[simp]
theorem eval_C : ∀ a, eval f (C a) = a :=
  eval₂_C _ _

@[simp]
theorem eval_X : ∀ n, eval f (X n) = f n :=
  eval₂_X _ _

@[simp]
theorem smul_eval (x) (p : MvPolynomial σ R) (s) : eval x (s • p) = s * eval x p := by
  rw [smul_eq_C_mul, (eval x).map_mul, eval_C]

theorem eval_add : eval f (p + q) = eval f p + eval f q :=
  eval₂_add _ _

theorem eval_mul : eval f (p * q) = eval f p * eval f q :=
  eval₂_mul _ _

theorem eval_pow : ∀ n, eval f (p ^ n) = eval f p ^ n :=
  fun _ => eval₂_pow _ _

theorem eval_sum {ι : Type*} (s : Finset ι) (f : ι → MvPolynomial σ R) (g : σ → R) :
    eval g (∑ i ∈ s, f i) = ∑ i ∈ s, eval g (f i) :=
  map_sum (eval g) _ _

@[to_additive existing]
theorem eval_prod {ι : Type*} (s : Finset ι) (f : ι → MvPolynomial σ R) (g : σ → R) :
    eval g (∏ i ∈ s, f i) = ∏ i ∈ s, eval g (f i) :=
  map_prod (eval g) _ _

theorem eval_assoc {τ} (f : σ → MvPolynomial τ R) (g : τ → R) (p : MvPolynomial σ R) :
    eval (eval g ∘ f) p = eval g (eval₂ C f p) := by
  rw [eval₂_comp_left (eval g)]
  unfold eval; simp only [coe_eval₂Hom]
  congr with a; simp

@[simp]
theorem eval₂_id {g : σ → R} (p : MvPolynomial σ R) : eval₂ (RingHom.id _) g p = eval g p :=
  rfl

theorem eval_eval₂ {S τ : Type*} {x : τ → S} [CommSemiring S]
    (f : R →+* MvPolynomial τ S) (g : σ → MvPolynomial τ S) (p : MvPolynomial σ R) :
    eval x (eval₂ f g p) = eval₂ ((eval x).comp f) (fun s => eval x (g s)) p := by
  apply induction_on p
  · simp
  · intro p q hp hq
    simp [hp, hq]
  · intro p n hp
    simp [hp]

end Eval

section Map

variable (f : R →+* S₁)

/-- `map f p` maps a polynomial `p` across a ring hom `f` -/
def map : MvPolynomial σ R →+* MvPolynomial σ S₁ :=
  eval₂Hom (C.comp f) X

@[simp]
theorem map_monomial (s : σ →₀ ℕ) (a : R) : map f (monomial s a) = monomial s (f a) :=
  (eval₂_monomial _ _).trans monomial_eq.symm

@[simp]
theorem map_C : ∀ a : R, map f (C a : MvPolynomial σ R) = C (f a) :=
  map_monomial _ _

@[simp]
theorem map_X : ∀ n : σ, map f (X n : MvPolynomial σ R) = X n :=
  eval₂_X _ _

theorem map_id : ∀ p : MvPolynomial σ R, map (RingHom.id R) p = p :=
  eval₂_eta

theorem map_map [CommSemiring S₂] (g : S₁ →+* S₂) (p : MvPolynomial σ R) :
    map g (map f p) = map (g.comp f) p :=
  (eval₂_comp_left (map g) (C.comp f) X p).trans <| by
    congr
    · ext1 a
      simp only [map_C, comp_apply, RingHom.coe_comp]
    · ext1 n
      simp only [map_X, comp_apply]

theorem eval₂_eq_eval_map (g : σ → S₁) (p : MvPolynomial σ R) : p.eval₂ f g = eval g (map f p) := by
  unfold map eval; simp only [coe_eval₂Hom]

  have h := eval₂_comp_left (eval₂Hom (RingHom.id S₁) g) (C.comp f) X p
  -- Porting note: the Lean 3 version of `h` was full of metavariables which
  -- were later unified during `rw [h]`. Also needed to add `-eval₂_id`.
  dsimp [-eval₂_id] at h
  rw [h]
  congr
  · ext1 a
    simp only [coe_eval₂Hom, RingHom.id_apply, comp_apply, eval₂_C, RingHom.coe_comp]
  · ext1 n
    simp only [comp_apply, eval₂_X]

theorem eval₂_comp_right {S₂} [CommSemiring S₂] (k : S₁ →+* S₂) (f : R →+* S₁) (g : σ → S₁) (p) :
    k (eval₂ f g p) = eval₂ k (k ∘ g) (map f p) := by
  apply MvPolynomial.induction_on p
  · intro r
    rw [eval₂_C, map_C, eval₂_C]
  · intro p q hp hq
    rw [eval₂_add, k.map_add, (map f).map_add, eval₂_add, hp, hq]
  · intro p s hp
    rw [eval₂_mul, k.map_mul, (map f).map_mul, eval₂_mul, map_X, hp, eval₂_X, eval₂_X]
    rfl

theorem map_eval₂ (f : R →+* S₁) (g : S₂ → MvPolynomial S₃ R) (p : MvPolynomial S₂ R) :
    map f (eval₂ C g p) = eval₂ C (map f ∘ g) (map f p) := by
  apply MvPolynomial.induction_on p
  · intro r
    rw [eval₂_C, map_C, map_C, eval₂_C]
  · intro p q hp hq
    rw [eval₂_add, (map f).map_add, hp, hq, (map f).map_add, eval₂_add]
  · intro p s hp
    rw [eval₂_mul, (map f).map_mul, hp, (map f).map_mul, map_X, eval₂_mul, eval₂_X, eval₂_X]
    rfl

theorem coeff_map (p : MvPolynomial σ R) : ∀ m : σ →₀ ℕ, coeff m (map f p) = f (coeff m p) := by
  classical
  apply MvPolynomial.induction_on p <;> clear p
  · intro r m
    rw [map_C]
    simp only [coeff_C]
    split_ifs
    · rfl
    rw [f.map_zero]
  · intro p q hp hq m
    simp only [hp, hq, (map f).map_add, coeff_add]
    rw [f.map_add]
  · intro p i hp m
    simp only [hp, (map f).map_mul, map_X]
    simp only [hp, mem_support_iff, coeff_mul_X']
    split_ifs
    · rfl
    rw [f.map_zero]

theorem map_injective (hf : Function.Injective f) :
    Function.Injective (map f : MvPolynomial σ R → MvPolynomial σ S₁) := by
  intro p q h
  simp only [MvPolynomial.ext_iff, coeff_map] at h ⊢
  intro m
  exact hf (h m)

theorem map_surjective (hf : Function.Surjective f) :
    Function.Surjective (map f : MvPolynomial σ R → MvPolynomial σ S₁) := fun p => by
  induction' p using MvPolynomial.induction_on' with i fr a b ha hb
  · obtain ⟨r, rfl⟩ := hf fr
    exact ⟨monomial i r, map_monomial _ _ _⟩
  · obtain ⟨a, rfl⟩ := ha
    obtain ⟨b, rfl⟩ := hb
    exact ⟨a + b, RingHom.map_add _ _ _⟩

/-- If `f` is a left-inverse of `g` then `map f` is a left-inverse of `map g`. -/
theorem map_leftInverse {f : R →+* S₁} {g : S₁ →+* R} (hf : Function.LeftInverse f g) :
    Function.LeftInverse (map f : MvPolynomial σ R → MvPolynomial σ S₁) (map g) := fun X => by
  rw [map_map, (RingHom.ext hf : f.comp g = RingHom.id _), map_id]

/-- If `f` is a right-inverse of `g` then `map f` is a right-inverse of `map g`. -/
theorem map_rightInverse {f : R →+* S₁} {g : S₁ →+* R} (hf : Function.RightInverse f g) :
    Function.RightInverse (map f : MvPolynomial σ R → MvPolynomial σ S₁) (map g) :=
  (map_leftInverse hf.leftInverse).rightInverse

@[simp]
theorem eval_map (f : R →+* S₁) (g : σ → S₁) (p : MvPolynomial σ R) :
    eval g (map f p) = eval₂ f g p := by
  apply MvPolynomial.induction_on p <;> · simp (config := { contextual := true })

@[simp]
theorem eval₂_map [CommSemiring S₂] (f : R →+* S₁) (g : σ → S₂) (φ : S₁ →+* S₂)
    (p : MvPolynomial σ R) : eval₂ φ g (map f p) = eval₂ (φ.comp f) g p := by
  rw [← eval_map, ← eval_map, map_map]

@[simp]
theorem eval₂Hom_map_hom [CommSemiring S₂] (f : R →+* S₁) (g : σ → S₂) (φ : S₁ →+* S₂)
    (p : MvPolynomial σ R) : eval₂Hom φ g (map f p) = eval₂Hom (φ.comp f) g p :=
  eval₂_map f g φ p

@[simp]
theorem constantCoeff_map (f : R →+* S₁) (φ : MvPolynomial σ R) :
    constantCoeff (MvPolynomial.map f φ) = f (constantCoeff φ) :=
  coeff_map f φ 0

theorem constantCoeff_comp_map (f : R →+* S₁) :
    (constantCoeff : MvPolynomial σ S₁ →+* S₁).comp (MvPolynomial.map f) = f.comp constantCoeff :=
  by ext <;> simp

theorem support_map_subset (p : MvPolynomial σ R) : (map f p).support ⊆ p.support := by
  intro x
  simp only [mem_support_iff]
  contrapose!
  change p.coeff x = 0 → (map f p).coeff x = 0
  rw [coeff_map]
  intro hx
  rw [hx]
  exact RingHom.map_zero f

theorem support_map_of_injective (p : MvPolynomial σ R) {f : R →+* S₁} (hf : Injective f) :
    (map f p).support = p.support := by
  apply Finset.Subset.antisymm
  · exact MvPolynomial.support_map_subset _ _
  intro x hx
  rw [mem_support_iff]
  contrapose! hx
  simp only [Classical.not_not, mem_support_iff]
  replace hx : (map f p).coeff x = 0 := hx
  rw [coeff_map, ← f.map_zero] at hx
  exact hf hx

theorem C_dvd_iff_map_hom_eq_zero (q : R →+* S₁) (r : R) (hr : ∀ r' : R, q r' = 0 ↔ r ∣ r')
    (φ : MvPolynomial σ R) : C r ∣ φ ↔ map q φ = 0 := by
  rw [C_dvd_iff_dvd_coeff, MvPolynomial.ext_iff]
  simp only [coeff_map, coeff_zero, hr]

theorem map_mapRange_eq_iff (f : R →+* S₁) (g : S₁ → R) (hg : g 0 = 0) (φ : MvPolynomial σ S₁) :
    map f (Finsupp.mapRange g hg φ) = φ ↔ ∀ d, f (g (coeff d φ)) = coeff d φ := by
  rw [MvPolynomial.ext_iff]
  apply forall_congr'; intro m
  rw [coeff_map]
  apply eq_iff_eq_cancel_right.mpr
  rfl

/-- If `f : S₁ →ₐ[R] S₂` is a morphism of `R`-algebras, then so is `MvPolynomial.map f`. -/
@[simps!]
def mapAlgHom [CommSemiring S₂] [Algebra R S₁] [Algebra R S₂] (f : S₁ →ₐ[R] S₂) :
    MvPolynomial σ S₁ →ₐ[R] MvPolynomial σ S₂ :=
  { map (↑f : S₁ →+* S₂) with
    commutes' := fun r => by
      have h₁ : algebraMap R (MvPolynomial σ S₁) r = C (algebraMap R S₁ r) := rfl
      have h₂ : algebraMap R (MvPolynomial σ S₂) r = C (algebraMap R S₂ r) := rfl
      simp_rw [OneHom.toFun_eq_coe]
      -- Porting note: we're missing some `simp` lemmas like `MonoidHom.coe_toOneHom`
      change @DFunLike.coe (_ →+* _) _ _ _ _ _ = _
      rw [h₁, h₂, map, eval₂Hom_C, RingHom.comp_apply, AlgHom.coe_toRingHom, AlgHom.commutes] }

@[simp]
theorem mapAlgHom_id [Algebra R S₁] :
    mapAlgHom (AlgHom.id R S₁) = AlgHom.id R (MvPolynomial σ S₁) :=
  AlgHom.ext map_id

@[simp]
theorem mapAlgHom_coe_ringHom [CommSemiring S₂] [Algebra R S₁] [Algebra R S₂] (f : S₁ →ₐ[R] S₂) :
    ↑(mapAlgHom f : _ →ₐ[R] MvPolynomial σ S₂) =
      (map ↑f : MvPolynomial σ S₁ →+* MvPolynomial σ S₂) :=
  RingHom.mk_coe _ _ _ _ _

end Map

section Aeval

/-! ### The algebra of multivariate polynomials -/


variable [Algebra R S₁] [CommSemiring S₂]
variable (f : σ → S₁)

@[simp]
theorem algebraMap_apply (r : R) : algebraMap R (MvPolynomial σ S₁) r = C (algebraMap R S₁ r) := rfl

/-- A map `σ → S₁` where `S₁` is an algebra over `R` generates an `R`-algebra homomorphism
from multivariate polynomials over `σ` to `S₁`. -/
def aeval : MvPolynomial σ R →ₐ[R] S₁ :=
  { eval₂Hom (algebraMap R S₁) f with commutes' := fun _r => eval₂_C _ _ _ }

theorem aeval_def (p : MvPolynomial σ R) : aeval f p = eval₂ (algebraMap R S₁) f p :=
  rfl

theorem aeval_eq_eval₂Hom (p : MvPolynomial σ R) : aeval f p = eval₂Hom (algebraMap R S₁) f p :=
  rfl

@[simp]
lemma coe_aeval_eq_eval : RingHomClass.toRingHom (MvPolynomial.aeval f) = MvPolynomial.eval f :=
  rfl

@[simp]
theorem aeval_X (s : σ) : aeval f (X s : MvPolynomial _ R) = f s :=
  eval₂_X _ _ _

theorem aeval_C (r : R) : aeval f (C r) = algebraMap R S₁ r :=
  eval₂_C _ _ _

theorem aeval_unique (φ : MvPolynomial σ R →ₐ[R] S₁) : φ = aeval (φ ∘ X) := by
  ext i
  simp

theorem aeval_X_left : aeval X = AlgHom.id R (MvPolynomial σ R) :=
  (aeval_unique (AlgHom.id R _)).symm

theorem aeval_X_left_apply (p : MvPolynomial σ R) : aeval X p = p :=
  AlgHom.congr_fun aeval_X_left p

theorem comp_aeval {B : Type*} [CommSemiring B] [Algebra R B] (φ : S₁ →ₐ[R] B) :
    φ.comp (aeval f) = aeval fun i => φ (f i) := by
  ext i
  simp

lemma comp_aeval_apply {B : Type*} [CommSemiring B] [Algebra R B] (φ : S₁ →ₐ[R] B)
    (p : MvPolynomial σ R) :
    φ (aeval f p) = aeval (fun i ↦ φ (f i)) p := by
  rw [← comp_aeval, AlgHom.coe_comp, comp_apply]

@[simp]
theorem map_aeval {B : Type*} [CommSemiring B] (g : σ → S₁) (φ : S₁ →+* B) (p : MvPolynomial σ R) :
    φ (aeval g p) = eval₂Hom (φ.comp (algebraMap R S₁)) (fun i => φ (g i)) p := by
  rw [← comp_eval₂Hom]
  rfl

@[simp]
theorem eval₂Hom_zero (f : R →+* S₂) : eval₂Hom f (0 : σ → S₂) = f.comp constantCoeff := by
  ext <;> simp

@[simp]
theorem eval₂Hom_zero' (f : R →+* S₂) : eval₂Hom f (fun _ => 0 : σ → S₂) = f.comp constantCoeff :=
  eval₂Hom_zero f

theorem eval₂Hom_zero_apply (f : R →+* S₂) (p : MvPolynomial σ R) :
    eval₂Hom f (0 : σ → S₂) p = f (constantCoeff p) :=
  RingHom.congr_fun (eval₂Hom_zero f) p

theorem eval₂Hom_zero'_apply (f : R →+* S₂) (p : MvPolynomial σ R) :
    eval₂Hom f (fun _ => 0 : σ → S₂) p = f (constantCoeff p) :=
  eval₂Hom_zero_apply f p

@[simp]
theorem eval₂_zero_apply (f : R →+* S₂) (p : MvPolynomial σ R) :
    eval₂ f (0 : σ → S₂) p = f (constantCoeff p) :=
  eval₂Hom_zero_apply _ _

@[simp]
theorem eval₂_zero'_apply (f : R →+* S₂) (p : MvPolynomial σ R) :
    eval₂ f (fun _ => 0 : σ → S₂) p = f (constantCoeff p) :=
  eval₂_zero_apply f p

@[simp]
theorem aeval_zero (p : MvPolynomial σ R) :
    aeval (0 : σ → S₁) p = algebraMap _ _ (constantCoeff p) :=
  eval₂Hom_zero_apply (algebraMap R S₁) p

@[simp]
theorem aeval_zero' (p : MvPolynomial σ R) :
    aeval (fun _ => 0 : σ → S₁) p = algebraMap _ _ (constantCoeff p) :=
  aeval_zero p

@[simp]
theorem eval_zero : eval (0 : σ → R) = constantCoeff :=
  eval₂Hom_zero _

@[simp]
theorem eval_zero' : eval (fun _ => 0 : σ → R) = constantCoeff :=
  eval₂Hom_zero _

theorem aeval_monomial (g : σ → S₁) (d : σ →₀ ℕ) (r : R) :
    aeval g (monomial d r) = algebraMap _ _ r * d.prod fun i k => g i ^ k :=
  eval₂Hom_monomial _ _ _ _

theorem eval₂Hom_eq_zero (f : R →+* S₂) (g : σ → S₂) (φ : MvPolynomial σ R)
    (h : ∀ d, φ.coeff d ≠ 0 → ∃ i ∈ d.support, g i = 0) : eval₂Hom f g φ = 0 := by
  rw [φ.as_sum, map_sum]
  refine Finset.sum_eq_zero fun d hd => ?_
  obtain ⟨i, hi, hgi⟩ : ∃ i ∈ d.support, g i = 0 := h d (Finsupp.mem_support_iff.mp hd)
  rw [eval₂Hom_monomial, Finsupp.prod, Finset.prod_eq_zero hi, mul_zero]
  rw [hgi, zero_pow]
  rwa [← Finsupp.mem_support_iff]

theorem aeval_eq_zero [Algebra R S₂] (f : σ → S₂) (φ : MvPolynomial σ R)
    (h : ∀ d, φ.coeff d ≠ 0 → ∃ i ∈ d.support, f i = 0) : aeval f φ = 0 :=
  eval₂Hom_eq_zero _ _ _ h

theorem aeval_sum {ι : Type*} (s : Finset ι) (φ : ι → MvPolynomial σ R) :
    aeval f (∑ i ∈ s, φ i) = ∑ i ∈ s, aeval f (φ i) :=
  map_sum (MvPolynomial.aeval f) _ _

@[to_additive existing]
theorem aeval_prod {ι : Type*} (s : Finset ι) (φ : ι → MvPolynomial σ R) :
    aeval f (∏ i ∈ s, φ i) = ∏ i ∈ s, aeval f (φ i) :=
  map_prod (MvPolynomial.aeval f) _ _

variable (R)

theorem _root_.Algebra.adjoin_range_eq_range_aeval :
    Algebra.adjoin R (Set.range f) = (MvPolynomial.aeval f).range := by
  simp only [← Algebra.map_top, ← MvPolynomial.adjoin_range_X, AlgHom.map_adjoin, ← Set.range_comp,
    Function.comp_def, MvPolynomial.aeval_X]

theorem _root_.Algebra.adjoin_eq_range (s : Set S₁) :
    Algebra.adjoin R s = (MvPolynomial.aeval ((↑) : s → S₁)).range := by
  rw [← Algebra.adjoin_range_eq_range_aeval, Subtype.range_coe]

end Aeval

section AevalTower

variable {S A B : Type*} [CommSemiring S] [CommSemiring A] [CommSemiring B]
variable [Algebra S R] [Algebra S A] [Algebra S B]

/-- Version of `aeval` for defining algebra homs out of `MvPolynomial σ R` over a smaller base ring
  than `R`. -/
def aevalTower (f : R →ₐ[S] A) (X : σ → A) : MvPolynomial σ R →ₐ[S] A :=
  { eval₂Hom (↑f) X with
    commutes' := fun r => by
      simp [IsScalarTower.algebraMap_eq S R (MvPolynomial σ R), algebraMap_eq] }

variable (g : R →ₐ[S] A) (y : σ → A)

@[simp]
theorem aevalTower_X (i : σ) : aevalTower g y (X i) = y i :=
  eval₂_X _ _ _

@[simp]
theorem aevalTower_C (x : R) : aevalTower g y (C x) = g x :=
  eval₂_C _ _ _

@[simp]
theorem aevalTower_comp_C : (aevalTower g y : MvPolynomial σ R →+* A).comp C = g :=
  RingHom.ext <| aevalTower_C _ _

theorem aevalTower_algebraMap (x : R) : aevalTower g y (algebraMap R (MvPolynomial σ R) x) = g x :=
  eval₂_C _ _ _

theorem aevalTower_comp_algebraMap :
    (aevalTower g y : MvPolynomial σ R →+* A).comp (algebraMap R (MvPolynomial σ R)) = g :=
  aevalTower_comp_C _ _

theorem aevalTower_toAlgHom (x : R) :
    aevalTower g y (IsScalarTower.toAlgHom S R (MvPolynomial σ R) x) = g x :=
  aevalTower_algebraMap _ _ _

@[simp]
theorem aevalTower_comp_toAlgHom :
    (aevalTower g y).comp (IsScalarTower.toAlgHom S R (MvPolynomial σ R)) = g :=
  AlgHom.coe_ringHom_injective <| aevalTower_comp_algebraMap _ _

@[simp]
theorem aevalTower_id :
    aevalTower (AlgHom.id S S) = (aeval : (σ → S) → MvPolynomial σ S →ₐ[S] S) := by
  ext
  simp only [aevalTower_X, aeval_X]

@[simp]
theorem aevalTower_ofId :
    aevalTower (Algebra.ofId S A) = (aeval : (σ → A) → MvPolynomial σ S →ₐ[S] A) := by
  ext
  simp only [aeval_X, aevalTower_X]

end AevalTower

section EvalMem

variable {S subS : Type*} [CommSemiring S] [SetLike subS S] [SubsemiringClass subS S]

theorem eval₂_mem {f : R →+* S} {p : MvPolynomial σ R} {s : subS}
    (hs : ∀ i ∈ p.support, f (p.coeff i) ∈ s) {v : σ → S} (hv : ∀ i, v i ∈ s) :
    MvPolynomial.eval₂ f v p ∈ s := by
  classical
  replace hs : ∀ i, f (p.coeff i) ∈ s := by
    intro i
    by_cases hi : i ∈ p.support
    · exact hs i hi
    · rw [MvPolynomial.not_mem_support_iff.1 hi, f.map_zero]
      exact zero_mem s
  induction' p using MvPolynomial.induction_on''' with a a b f ha _ ih
  · simpa using hs 0
  rw [eval₂_add, eval₂_monomial]
  refine add_mem (mul_mem ?_ <| prod_mem fun i _ => pow_mem (hv _) _) (ih fun i => ?_)
  · have := hs a -- Porting note: was `simpa only [...]`
    rwa [coeff_add, MvPolynomial.not_mem_support_iff.1 ha, add_zero, coeff_monomial,
      if_pos rfl] at this
  have := hs i
  rw [coeff_add, coeff_monomial] at this
  split_ifs at this with h
  · subst h
    rw [MvPolynomial.not_mem_support_iff.1 ha, map_zero]
    exact zero_mem _
  · rwa [zero_add] at this

theorem eval_mem {p : MvPolynomial σ S} {s : subS} (hs : ∀ i ∈ p.support, p.coeff i ∈ s) {v : σ → S}
    (hv : ∀ i, v i ∈ s) : MvPolynomial.eval v p ∈ s :=
  eval₂_mem hs hv

end EvalMem

variable {S T : Type*} [CommSemiring S] [Algebra R S] [CommSemiring T] [Algebra R T] [Algebra S T]
  [IsScalarTower R S T]

lemma aeval_sum_elim {σ τ : Type*} (p : MvPolynomial (σ ⊕ τ) R) (f : τ → S) (g : σ → T) :
    (aeval (Sum.elim g (algebraMap S T ∘ f))) p =
      (aeval g) ((aeval (Sum.elim X (C ∘ f))) p) := by
  induction' p using MvPolynomial.induction_on with r p q hp hq p i h
  · simp [← IsScalarTower.algebraMap_apply]
  · simp [hp, hq]
  · cases i <;> simp [h]

end CommSemiring

end MvPolynomial

set_option linter.style.longFile 1700
