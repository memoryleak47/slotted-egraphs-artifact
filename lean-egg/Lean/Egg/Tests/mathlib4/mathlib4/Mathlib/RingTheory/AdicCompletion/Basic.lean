import Mathlib.Testing.Egg.SimpOnlyOverride
/-
Copyright (c) 2020 Kenny Lau. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kenny Lau, Judith Ludwig, Christian Merten
-/
import Mathlib.Algebra.GeomSum
import Mathlib.LinearAlgebra.SModEq
import Mathlib.RingTheory.JacobsonIdeal

/-!
# Completion of a module with respect to an ideal.

In this file we define the notions of Hausdorff, precomplete, and complete for an `R`-module `M`
with respect to an ideal `I`:

## Main definitions

- `IsHausdorff I M`: this says that the intersection of `I^n M` is `0`.
- `IsPrecomplete I M`: this says that every Cauchy sequence converges.
- `IsAdicComplete I M`: this says that `M` is Hausdorff and precomplete.
- `Hausdorffification I M`: this is the universal Hausdorff module with a map from `M`.
- `AdicCompletion I M`: if `I` is finitely generated, then this is the universal complete module
  (TODO) with a map from `M`. This map is injective iff `M` is Hausdorff and surjective iff `M` is
  precomplete.

-/

suppress_compilation

open Submodule

variable {R : Type*} [CommRing R] (I : Ideal R)
variable (M : Type*) [AddCommGroup M] [Module R M]
variable {N : Type*} [AddCommGroup N] [Module R N]

/-- A module `M` is Hausdorff with respect to an ideal `I` if `⋂ I^n M = 0`. -/
class IsHausdorff : Prop where
  haus' : ∀ x : M, (∀ n : ℕ, x ≡ 0 [SMOD (I ^ n • ⊤ : Submodule R M)]) → x = 0

/-- A module `M` is precomplete with respect to an ideal `I` if every Cauchy sequence converges. -/
class IsPrecomplete : Prop where
  prec' : ∀ f : ℕ → M, (∀ {m n}, m ≤ n → f m ≡ f n [SMOD (I ^ m • ⊤ : Submodule R M)]) →
    ∃ L : M, ∀ n, f n ≡ L [SMOD (I ^ n • ⊤ : Submodule R M)]

/-- A module `M` is `I`-adically complete if it is Hausdorff and precomplete. -/
class IsAdicComplete extends IsHausdorff I M, IsPrecomplete I M : Prop

variable {I M}

theorem IsHausdorff.haus (_ : IsHausdorff I M) :
    ∀ x : M, (∀ n : ℕ, x ≡ 0 [SMOD (I ^ n • ⊤ : Submodule R M)]) → x = 0 :=
  IsHausdorff.haus'

theorem isHausdorff_iff :
    IsHausdorff I M ↔ ∀ x : M, (∀ n : ℕ, x ≡ 0 [SMOD (I ^ n • ⊤ : Submodule R M)]) → x = 0 :=
  ⟨IsHausdorff.haus, fun h => ⟨h⟩⟩

theorem IsPrecomplete.prec (_ : IsPrecomplete I M) {f : ℕ → M} :
    (∀ {m n}, m ≤ n → f m ≡ f n [SMOD (I ^ m • ⊤ : Submodule R M)]) →
      ∃ L : M, ∀ n, f n ≡ L [SMOD (I ^ n • ⊤ : Submodule R M)] :=
  IsPrecomplete.prec' _

theorem isPrecomplete_iff :
    IsPrecomplete I M ↔
      ∀ f : ℕ → M,
        (∀ {m n}, m ≤ n → f m ≡ f n [SMOD (I ^ m • ⊤ : Submodule R M)]) →
          ∃ L : M, ∀ n, f n ≡ L [SMOD (I ^ n • ⊤ : Submodule R M)] :=
  ⟨fun h => h.1, fun h => ⟨h⟩⟩

variable (I M)

/-- The Hausdorffification of a module with respect to an ideal. -/
abbrev Hausdorffification : Type _ :=
  M ⧸ (⨅ n : ℕ, I ^ n • ⊤ : Submodule R M)

/-- The canonical linear map `M ⧸ (I ^ n • ⊤) →ₗ[R] M ⧸ (I ^ m • ⊤)` for `m ≤ n` used
to define `AdicCompletion`. -/
def AdicCompletion.transitionMap {m n : ℕ} (hmn : m ≤ n) :
    M ⧸ (I ^ n • ⊤ : Submodule R M) →ₗ[R] M ⧸ (I ^ m • ⊤ : Submodule R M) :=
  liftQ (I ^ n • ⊤ : Submodule R M) (mkQ (I ^ m • ⊤ : Submodule R M)) (by
    rw [ker_mkQ]
    exact smul_mono (Ideal.pow_le_pow_right hmn) le_rfl)

/-- The completion of a module with respect to an ideal. This is not necessarily Hausdorff.
In fact, this is only complete if the ideal is finitely generated. -/
def AdicCompletion : Type _ :=
  { f : ∀ n : ℕ, M ⧸ (I ^ n • ⊤ : Submodule R M) //
    ∀ {m n} (hmn : m ≤ n), AdicCompletion.transitionMap I M hmn (f n) = f m }

namespace IsHausdorff

instance bot : IsHausdorff (⊥ : Ideal R) M :=
  ⟨fun x hx => by simpa only [pow_one ⊥, bot_smul, SModEq.bot] using hx 1⟩

variable {M}

protected theorem subsingleton (h : IsHausdorff (⊤ : Ideal R) M) : Subsingleton M :=
  ⟨fun x y => eq_of_sub_eq_zero <| h.haus (x - y) fun n => by
    rw [Ideal.top_pow, top_smul]
    exact SModEq.top⟩

variable (M)

instance (priority := 100) of_subsingleton [Subsingleton M] : IsHausdorff I M :=
  ⟨fun _ _ => Subsingleton.elim _ _⟩

variable {I M}

theorem iInf_pow_smul (h : IsHausdorff I M) : (⨅ n : ℕ, I ^ n • ⊤ : Submodule R M) = ⊥ :=
  eq_bot_iff.2 fun x hx =>
    (mem_bot _).2 <| h.haus x fun n => SModEq.zero.2 <| (mem_iInf fun n : ℕ => I ^ n • ⊤).1 hx n

end IsHausdorff

namespace Hausdorffification

/-- The canonical linear map to the Hausdorffification. -/
def of : M →ₗ[R] Hausdorffification I M :=
  mkQ _

variable {I M}

@[elab_as_elim]
theorem induction_on {C : Hausdorffification I M → Prop} (x : Hausdorffification I M)
    (ih : ∀ x, C (of I M x)) : C x :=
  Quotient.inductionOn' x ih

variable (I M)

instance : IsHausdorff I (Hausdorffification I M) :=
  ⟨fun x => Quotient.inductionOn' x fun x hx =>
    (Quotient.mk_eq_zero _).2 <| (mem_iInf _).2 fun n => by
      have := comap_map_mkQ (⨅ n : ℕ, I ^ n • ⊤ : Submodule R M) (I ^ n • ⊤)
      simp only [sup_of_le_right (iInf_le (fun n => (I ^ n • ⊤ : Submodule R M)) n)] at this
      rw [← this, map_smul'', mem_comap, Submodule.map_top, range_mkQ, ← SModEq.zero]
      exact hx n⟩

variable {M} [h : IsHausdorff I N]

/-- Universal property of Hausdorffification: any linear map to a Hausdorff module extends to a
unique map from the Hausdorffification. -/
def lift (f : M →ₗ[R] N) : Hausdorffification I M →ₗ[R] N :=
  liftQ _ f <| map_le_iff_le_comap.1 <| h.iInf_pow_smul ▸ le_iInf fun n =>
    le_trans (map_mono <| iInf_le _ n) <| by
      rw [map_smul'']
      exact smul_mono le_rfl le_top

theorem lift_of (f : M →ₗ[R] N) (x : M) : lift I f (of I M x) = f x :=
  rfl

theorem lift_comp_of (f : M →ₗ[R] N) : (lift I f).comp (of I M) = f :=
  LinearMap.ext fun _ => rfl

/-- Uniqueness of lift. -/
theorem lift_eq (f : M →ₗ[R] N) (g : Hausdorffification I M →ₗ[R] N) (hg : g.comp (of I M) = f) :
    g = lift I f :=
  LinearMap.ext fun x => induction_on x fun x => by rw [lift_of, ← hg, LinearMap.comp_apply]

end Hausdorffification

namespace IsPrecomplete

instance bot : IsPrecomplete (⊥ : Ideal R) M := by
  refine ⟨fun f hf => ⟨f 1, fun n => ?_⟩⟩
  cases' n with n
  · rw [pow_zero, Ideal.one_eq_top, top_smul]
    exact SModEq.top
  specialize hf (Nat.le_add_left 1 n)
  rw [pow_one, bot_smul, SModEq.bot] at hf; rw [hf]

instance top : IsPrecomplete (⊤ : Ideal R) M :=
  ⟨fun f _ =>
    ⟨0, fun n => by
      rw [Ideal.top_pow, top_smul]
      exact SModEq.top⟩⟩

instance (priority := 100) of_subsingleton [Subsingleton M] : IsPrecomplete I M :=
  ⟨fun f _ => ⟨0, fun n => by rw [Subsingleton.elim (f n) 0]⟩⟩

end IsPrecomplete

namespace AdicCompletion

/-- `AdicCompletion` is the submodule of compatible families in
`∀ n : ℕ, M ⧸ (I ^ n • ⊤)`. -/
def submodule : Submodule R (∀ n : ℕ, M ⧸ (I ^ n • ⊤ : Submodule R M)) where
  carrier := { f | ∀ {m n} (hmn : m ≤ n), AdicCompletion.transitionMap I M hmn (f n) = f m }
  zero_mem' hmn := by rw [Pi.zero_apply, Pi.zero_apply, LinearMap.map_zero]
  add_mem' hf hg m n hmn := by
    rw [Pi.add_apply, Pi.add_apply, LinearMap.map_add, hf hmn, hg hmn]
  smul_mem' c f hf m n hmn := by rw [Pi.smul_apply, Pi.smul_apply, LinearMap.map_smul, hf hmn]

instance : Zero (AdicCompletion I M) where
  zero := ⟨0, by simp⟩

instance : Add (AdicCompletion I M) where
  add x y := ⟨x.val + y.val, by simp [x.property, y.property]⟩

instance : Neg (AdicCompletion I M) where
  neg x := ⟨- x.val, by simp [x.property]⟩

instance : Sub (AdicCompletion I M) where
  sub x y := ⟨x.val - y.val, by simp [x.property, y.property]⟩

instance : SMul ℕ (AdicCompletion I M) where
  smul n x := ⟨n • x.val, by simp [x.property]⟩

instance : SMul ℤ (AdicCompletion I M) where
  smul n x := ⟨n • x.val, by simp [x.property]⟩

instance : AddCommGroup (AdicCompletion I M) :=
  let f : AdicCompletion I M → ∀ n, M ⧸ (I ^ n • ⊤ : Submodule R M) := Subtype.val
  Subtype.val_injective.addCommGroup f rfl (fun _ _ ↦ rfl) (fun _ ↦ rfl) (fun _ _ ↦ rfl)
    (fun _ _ ↦ rfl) (fun _ _ ↦ rfl)

instance : SMul R (AdicCompletion I M) where
  smul r x := ⟨r • x.val, by simp [x.property]⟩

instance : Module R (AdicCompletion I M) :=
  let f : AdicCompletion I M →+ ∀ n, M ⧸ (I ^ n • ⊤ : Submodule R M) :=
    { toFun := Subtype.val, map_zero' := rfl, map_add' := fun _ _ ↦ rfl }
  Subtype.val_injective.module R f (fun _ _ ↦ rfl)

/-- The canonical inclusion from the completion to the product. -/
@[simps]
def incl : AdicCompletion I M →ₗ[R] (∀ n, M ⧸ (I ^ n • ⊤ : Submodule R M)) where
  toFun x := x.val
  map_add' _ _ := rfl
  map_smul' _ _ := rfl

/-- The canonical linear map to the completion. -/
def of : M →ₗ[R] AdicCompletion I M where
  toFun x := ⟨fun n => mkQ (I ^ n • ⊤ : Submodule R M) x, fun _ => rfl⟩
  map_add' _ _ := rfl
  map_smul' _ _ := rfl

@[simp]
theorem of_apply (x : M) (n : ℕ) : (of I M x).1 n = mkQ (I ^ n • ⊤ : Submodule R M) x :=
  rfl

/-- Linearly evaluating a sequence in the completion at a given input. -/
def eval (n : ℕ) : AdicCompletion I M →ₗ[R] M ⧸ (I ^ n • ⊤ : Submodule R M) where
  toFun f := f.1 n
  map_add' _ _ := rfl
  map_smul' _ _ := rfl

@[simp]
theorem coe_eval (n : ℕ) :
    (eval I M n : AdicCompletion I M → M ⧸ (I ^ n • ⊤ : Submodule R M)) = fun f => f.1 n :=
  rfl

theorem eval_apply (n : ℕ) (f : AdicCompletion I M) : eval I M n f = f.1 n :=
  rfl

theorem eval_of (n : ℕ) (x : M) : eval I M n (of I M x) = mkQ (I ^ n • ⊤ : Submodule R M) x :=
  rfl

@[simp]
theorem eval_comp_of (n : ℕ) : (eval I M n).comp (of I M) = mkQ _ :=
  rfl

theorem eval_surjective (n : ℕ) : Function.Surjective (eval I M n) := fun x ↦
  Quotient.inductionOn' x fun x ↦ ⟨of I M x, rfl⟩

@[simp]
theorem range_eval (n : ℕ) : LinearMap.range (eval I M n) = ⊤ :=
  LinearMap.range_eq_top.2 (eval_surjective I M n)

@[simp]
theorem val_zero (n : ℕ) : (0 : AdicCompletion I M).val n = 0 :=
  rfl

variable {I M}

@[simp]
theorem val_add (n : ℕ) (f g : AdicCompletion I M) : (f + g).val n = f.val n + g.val n :=
  rfl

@[simp]
theorem val_sub (n : ℕ) (f g : AdicCompletion I M) : (f - g).val n = f.val n - g.val n :=
  rfl

@[simp]
theorem val_sum {α : Type*} (s : Finset α) (f : α → AdicCompletion I M) (n : ℕ) :
    (Finset.sum s f).val n = Finset.sum s (fun a ↦ (f a).val n) := by
  simp_rw [← incl_apply, map_sum, Finset.sum_apply]

/- No `simp` attribute, since it causes `simp` unification timeouts when considering
the `AdicCompletion I R` module instance on `AdicCompletion I M` (see `AdicCompletion/Algebra`). -/
theorem val_smul (n : ℕ) (r : R) (f : AdicCompletion I M) : (r • f).val n = r • f.val n :=
  rfl

@[ext]
theorem ext {x y : AdicCompletion I M} (h : ∀ n, x.val n = y.val n) : x = y :=
  Subtype.eq <| funext h

variable (I M)

instance : IsHausdorff I (AdicCompletion I M) where
  haus' x h := ext fun n ↦ by
    refine smul_induction_on (SModEq.zero.1 <| h n) (fun r hr x _ ↦ ?_) (fun x y hx hy ↦ ?_)
    · simp only [val_smul, val_zero]
      exact Quotient.inductionOn' (x.val n)
        (fun a ↦ SModEq.zero.2 <| smul_mem_smul hr mem_top)
    · simp only [val_add, hx, val_zero, hy, add_zero]

@[simp]
theorem transitionMap_mk {m n : ℕ} (hmn : m ≤ n) (x : M) :
    transitionMap I M hmn
      (Submodule.Quotient.mk (p := (I ^ n • ⊤ : Submodule R M)) x) =
      Submodule.Quotient.mk (p := (I ^ m • ⊤ : Submodule R M)) x := by
  rfl

@[simp]
theorem transitionMap_eq (n : ℕ) : transitionMap I M (Nat.le_refl n) = LinearMap.id := by
  ext
  simp

@[simp]
theorem transitionMap_comp {m n k : ℕ} (hmn : m ≤ n) (hnk : n ≤ k) :
    transitionMap I M hmn ∘ₗ transitionMap I M hnk = transitionMap I M (hmn.trans hnk) := by
  ext
  simp

@[simp]
theorem transitionMap_comp_apply {m n k : ℕ} (hmn : m ≤ n) (hnk : n ≤ k)
    (x : M ⧸ (I ^ k • ⊤ : Submodule R M)) :
    transitionMap I M hmn (transitionMap I M hnk x) = transitionMap I M (hmn.trans hnk) x := by
  change (transitionMap I M hmn ∘ₗ transitionMap I M hnk) x = transitionMap I M (hmn.trans hnk) x
  simp

@[simp]
theorem transitionMap_comp_eval_apply {m n : ℕ} (hmn : m ≤ n) (x : AdicCompletion I M) :
    transitionMap I M hmn (x.val n) = x.val m :=
  x.property hmn

@[simp]
theorem transitionMap_comp_eval {m n : ℕ} (hmn : m ≤ n) :
    transitionMap I M hmn ∘ₗ eval I M n = eval I M m := by
  ext x
  simp

/-- A sequence `ℕ → M` is an `I`-adic Cauchy sequence if for every `m ≤ n`,
`f m ≡ f n` modulo `I ^ m • ⊤`. -/
def IsAdicCauchy (f : ℕ → M) : Prop :=
  ∀ {m n}, m ≤ n → f m ≡ f n [SMOD (I ^ m • ⊤ : Submodule R M)]

/-- The type of `I`-adic Cauchy sequences. -/
def AdicCauchySequence : Type _ := { f : ℕ → M // IsAdicCauchy I M f }

namespace AdicCauchySequence

/-- The type of `I`-adic cauchy sequences is a submodule of the product `ℕ → M`. -/
def submodule : Submodule R (ℕ → M) where
  carrier := { f | IsAdicCauchy I M f }
  add_mem' := by
    intro f g hf hg m n hmn
    exact SModEq.add (hf hmn) (hg hmn)
  zero_mem' := by
    intro _ _ _
    rfl
  smul_mem' := by
    intro r f hf m n hmn
    exact SModEq.smul (hf hmn) r

instance : Zero (AdicCauchySequence I M) where
  zero := ⟨0, fun _ ↦ rfl⟩

instance : Add (AdicCauchySequence I M) where
  add x y := ⟨x.val + y.val, fun hmn ↦ SModEq.add (x.property hmn) (y.property hmn)⟩

instance : Neg (AdicCauchySequence I M) where
  neg x := ⟨- x.val, fun hmn ↦ SModEq.neg (x.property hmn)⟩

instance : Sub (AdicCauchySequence I M) where
  sub x y := ⟨x.val - y.val, fun hmn ↦ SModEq.sub (x.property hmn) (y.property hmn)⟩

instance : SMul ℕ (AdicCauchySequence I M) where
  smul n x := ⟨n • x.val, fun hmn ↦ SModEq.nsmul (x.property hmn) n⟩

instance : SMul ℤ (AdicCauchySequence I M) where
  smul n x := ⟨n • x.val, fun hmn ↦ SModEq.zsmul (x.property hmn) n⟩

instance : AddCommGroup (AdicCauchySequence I M) := by
  let f : AdicCauchySequence I M → (ℕ → M) := Subtype.val
  apply Subtype.val_injective.addCommGroup f rfl (fun _ _ ↦ rfl) (fun _ ↦ rfl) (fun _ _ ↦ rfl)
    (fun _ _ ↦ rfl) (fun _ _ ↦ rfl)

instance : SMul R (AdicCauchySequence I M) where
  smul r x := ⟨r • x.val, fun hmn ↦ SModEq.smul (x.property hmn) r⟩

instance : Module R (AdicCauchySequence I M) :=
  let f : AdicCauchySequence I M →+ (ℕ → M) :=
    { toFun := Subtype.val, map_zero' := rfl, map_add' := fun _ _ ↦ rfl }
  Subtype.val_injective.module R f (fun _ _ ↦ rfl)

instance : CoeFun (AdicCauchySequence I M) (fun _ ↦ ℕ → M) where
  coe f := f.val

@[simp]
theorem zero_apply (n : ℕ) : (0 : AdicCauchySequence I M) n = 0 :=
  rfl

variable {I M}

@[simp]
theorem add_apply (n : ℕ) (f g : AdicCauchySequence I M) : (f + g) n = f n + g n :=
  rfl

@[simp]
theorem sub_apply (n : ℕ) (f g : AdicCauchySequence I M) : (f - g) n = f n - g n :=
  rfl

@[simp]
theorem smul_apply (n : ℕ) (r : R) (f : AdicCauchySequence I M) : (r • f) n = r • f n :=
  rfl

@[ext]
theorem ext {x y : AdicCauchySequence I M} (h : ∀ n, x n = y n) : x = y :=
  Subtype.eq <| funext h

/-- The defining property of an adic cauchy sequence unwrapped. -/
theorem mk_eq_mk {m n : ℕ} (hmn : m ≤ n) (f : AdicCauchySequence I M) :
    Submodule.Quotient.mk (p := (I ^ m • ⊤ : Submodule R M)) (f n) =
      Submodule.Quotient.mk (p := (I ^ m • ⊤ : Submodule R M)) (f m) :=
  (f.property hmn).symm

end AdicCauchySequence

/-- The `I`-adic cauchy condition can be checked on successive `n`.-/
theorem isAdicCauchy_iff (f : ℕ → M) :
    IsAdicCauchy I M f ↔ ∀ n, f n ≡ f (n + 1) [SMOD (I ^ n • ⊤ : Submodule R M)] := by
  constructor
  · intro h n
    exact h (Nat.le_succ n)
  · intro h m n hmn
    induction n, hmn using Nat.le_induction with
    | base => rfl
    | succ n hmn ih =>
        trans
        · exact ih
        · refine SModEq.mono (smul_mono (Ideal.pow_le_pow_right hmn) (by rfl)) (h n)

/-- Construct `I`-adic cauchy sequence from sequence satisfying the successive cauchy condition. -/
@[simps]
def AdicCauchySequence.mk (f : ℕ → M)
    (h : ∀ n, f n ≡ f (n + 1) [SMOD (I ^ n • ⊤ : Submodule R M)]) : AdicCauchySequence I M where
  val := f
  property := by rwa [isAdicCauchy_iff]

/-- The canonical linear map from cauchy sequences to the completion. -/
@[simps]
def mk : AdicCauchySequence I M →ₗ[R] AdicCompletion I M where
  toFun f := ⟨fun n ↦ Submodule.mkQ (I ^ n • ⊤ : Submodule R M) (f n), by
    intro m n hmn
    simp only [mkQ_apply, transitionMap_mk]
    exact (f.property hmn).symm⟩
  map_add' _ _ := rfl
  map_smul' _ _ := rfl

/-- Criterion for checking that an adic cauchy sequence is mapped to zero in the adic completion. -/
theorem mk_zero_of (f : AdicCauchySequence I M)
    (h : ∃ k : ℕ, ∀ n ≥ k, ∃ m ≥ n, ∃ l ≥ n, f m ∈ (I ^ l • ⊤ : Submodule R M)) :
    AdicCompletion.mk I M f = 0 := by
  obtain ⟨k, h⟩ := h
  ext n
  obtain ⟨m, hnm, l, hnl, hl⟩ := h (n + k) (by omega)
  rw [mk_apply_coe, Submodule.mkQ_apply, val_zero,
    ← AdicCauchySequence.mk_eq_mk (show n ≤ m by omega)]
  simpa using (Submodule.smul_mono_left (Ideal.pow_le_pow_right (by omega))) hl

/-- Every element in the adic completion is represented by a Cauchy sequence. -/
theorem mk_surjective : Function.Surjective (mk I M) := by
  intro x
  choose a ha using fun n ↦ Submodule.Quotient.mk_surjective _ (x.val n)
  refine ⟨⟨a, ?_⟩, ?_⟩
  · intro m n hmn
    rw [SModEq.def, ha m, ← transitionMap_mk I M hmn, ha n, x.property hmn]
  · ext n
    simp [ha n]

/-- To show a statement about an element of `adicCompletion I M`, it suffices to check it
on Cauchy sequences. -/
theorem induction_on {p : AdicCompletion I M → Prop} (x : AdicCompletion I M)
    (h : ∀ (f : AdicCauchySequence I M), p (mk I M f)) : p x := by
  obtain ⟨f, rfl⟩ := mk_surjective I M x
  exact h f

variable {M}

/-- Lift a compatible family of linear maps `M →ₗ[R] N ⧸ (I ^ n • ⊤ : Submodule R N)` to
the `I`-adic completion of `M`. -/
def lift (f : ∀ (n : ℕ), M →ₗ[R] N ⧸ (I ^ n • ⊤ : Submodule R N))
    (h : ∀ {m n : ℕ} (hle : m ≤ n), transitionMap I N hle ∘ₗ f n = f m) :
    M →ₗ[R] AdicCompletion I N where
  toFun := fun x ↦ ⟨fun n ↦ f n x, fun hkl ↦ LinearMap.congr_fun (h hkl) x⟩
  map_add' x y := by
    simp only [map_add]
    rfl
  map_smul' r x := by
    simp only [LinearMapClass.map_smul, RingHom.id_apply]
    rfl

@[simp]
lemma eval_lift (f : ∀ (n : ℕ), M →ₗ[R] N ⧸ (I ^ n • ⊤ : Submodule R N))
    (h : ∀ {m n : ℕ} (hle : m ≤ n), transitionMap I N hle ∘ₗ f n = f m)
    (n : ℕ) : eval I N n ∘ₗ lift I f h = f n :=
  rfl

@[simp]
lemma eval_lift_apply (f : ∀ (n : ℕ), M →ₗ[R] N ⧸ (I ^ n • ⊤ : Submodule R N))
    (h : ∀ {m n : ℕ} (hle : m ≤ n), transitionMap I N hle ∘ₗ f n = f m)
    (n : ℕ) (x : M) : (lift I f h x).val n = f n x :=
  rfl

end AdicCompletion

namespace IsAdicComplete

instance bot : IsAdicComplete (⊥ : Ideal R) M where

protected theorem subsingleton (h : IsAdicComplete (⊤ : Ideal R) M) : Subsingleton M :=
  h.1.subsingleton

instance (priority := 100) of_subsingleton [Subsingleton M] : IsAdicComplete I M where

open Finset

theorem le_jacobson_bot [IsAdicComplete I R] : I ≤ (⊥ : Ideal R).jacobson := by
  intro x hx
  rw [← Ideal.neg_mem_iff, Ideal.mem_jacobson_bot]
  intro y
  rw [add_comm]
  let f : ℕ → R := fun n => ∑ i ∈ range n, (x * y) ^ i
  have hf : ∀ m n, m ≤ n → f m ≡ f n [SMOD I ^ m • (⊤ : Submodule R R)] := by
    intro m n h
    simp only [f, Algebra.id.smul_eq_mul, Ideal.mul_top, SModEq.sub_mem]
    rw [← add_tsub_cancel_of_le h, Finset.sum_range_add, ← sub_sub, sub_self, zero_sub,
      @neg_mem_iff]
    apply Submodule.sum_mem
    intro n _
    rw [mul_pow, pow_add, mul_assoc]
    exact Ideal.mul_mem_right _ (I ^ m) (Ideal.pow_mem_pow hx m)
  obtain ⟨L, hL⟩ := IsPrecomplete.prec toIsPrecomplete @hf
  rw [isUnit_iff_exists_inv]
  use L
  rw [← sub_eq_zero, neg_mul]
  apply IsHausdorff.haus (toIsHausdorff : IsHausdorff I R)
  intro n
  specialize hL n
  rw [SModEq.sub_mem, Algebra.id.smul_eq_mul, Ideal.mul_top] at hL ⊢
  rw [sub_zero]
  suffices (1 - x * y) * f n - 1 ∈ I ^ n by
    convert Ideal.sub_mem _ this (Ideal.mul_mem_left _ (1 + -(x * y)) hL) using 1
    ring
  cases n
  · simp only [Ideal.one_eq_top, pow_zero, mem_top]
  · rw [← neg_sub _ (1 : R), neg_mul, mul_geom_sum, neg_sub, sub_sub, add_comm (_ ^ _), ← sub_sub,
      sub_self, zero_sub, @neg_mem_iff, mul_pow]
    exact Ideal.mul_mem_right _ (I ^ _) (Ideal.pow_mem_pow hx _)

end IsAdicComplete
