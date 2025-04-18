import Mathlib.Testing.Egg.SimpOnlyOverride
/-
Copyright (c) 2024 Andrew Yang. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Andrew Yang
-/
import Mathlib.Algebra.Module.LocalizedModule
import Mathlib.LinearAlgebra.Quotient.Basic
import Mathlib.RingTheory.Localization.Module

/-!
# Localization of Submodules

Results about localizations of submodules and quotient modules are provided in this file.

## Main result
- `Submodule.localized`:
  The localization of an `R`-submodule of `M` at `p` viewed as an `Rₚ`-submodule of `Mₚ`.
- `Submodule.toLocalized`:
  The localization map of a submodule `M' →ₗ[R] M'.localized p`.
- `Submodule.toLocalizedQuotient`:
  The localization map of a quotient module `M ⧸ M' →ₗ[R] LocalizedModule p M ⧸ M'.localized p`.

## TODO
- Statements regarding the exactness of localization.
- Connection with flatness.

-/

open nonZeroDivisors

universe u u' v v' w w'

variable {R : Type u} (S : Type u') {M : Type v} {N : Type v'}
variable [CommRing R] [CommRing S] [AddCommGroup M] [AddCommGroup N]
variable [Module R M] [Module R N] [Algebra R S] [Module S N] [IsScalarTower R S N]
variable (p : Submonoid R) [IsLocalization p S] (f : M →ₗ[R] N) [IsLocalizedModule p f]
variable (hp : p ≤ R⁰)
variable (M' : Submodule R M)

/-- Let `S` be the localization of `R` at `p` and `N` be the localization of `M` at `p`.
This is the localization of an `R`-submodule of `M` viewed as an `S`-submodule of `N`. -/
def Submodule.localized' : Submodule S N where
  carrier := { x | ∃ m ∈ M', ∃ s : p, IsLocalizedModule.mk' f m s = x }
  add_mem' := fun {x} {y} ⟨m, hm, s, hx⟩ ⟨n, hn, t, hy⟩ ↦ ⟨t • m + s • n, add_mem (M'.smul_mem t hm)
    (M'.smul_mem s hn), s * t, by rw [← hx, ← hy, IsLocalizedModule.mk'_add_mk']⟩
  zero_mem' := ⟨0, zero_mem _, 1, by simp⟩
  smul_mem' := fun r x h ↦ by
    have ⟨m, hm, s, hx⟩ := h
    have ⟨y, t, hyt⟩ := IsLocalization.mk'_surjective p r
    exact ⟨y • m, M'.smul_mem y hm, t * s, by simp [← hyt, ← hx, IsLocalizedModule.mk'_smul_mk']⟩

lemma Submodule.mem_localized' (x : N) :
    x ∈ Submodule.localized' S p f M' ↔ ∃ m ∈ M', ∃ s : p, IsLocalizedModule.mk' f m s = x :=
  Iff.rfl

/-- The localization of an `R`-submodule of `M` at `p` viewed as an `Rₚ`-submodule of `Mₚ`. -/
abbrev Submodule.localized : Submodule (Localization p) (LocalizedModule p M) :=
  M'.localized' (Localization p) p (LocalizedModule.mkLinearMap p M)

@[simp]
lemma Submodule.localized'_bot : (⊥ : Submodule R M).localized' S p f = ⊥ := by
  rw [← le_bot_iff]
  rintro _ ⟨_, rfl, s, rfl⟩
  simp only [IsLocalizedModule.mk'_zero, mem_bot]

@[simp]
lemma Submodule.localized'_top : (⊤ : Submodule R M).localized' S p f = ⊤ := by
  rw [← top_le_iff]
  rintro x _
  obtain ⟨⟨x, s⟩, rfl⟩ := IsLocalizedModule.mk'_surjective p f x
  exact ⟨x, trivial, s, rfl⟩

@[simp]
lemma Submodule.localized'_span (s : Set M) : (span R s).localized' S p f = span S (f '' s) := by
  apply le_antisymm
  · rintro _ ⟨x, hx, t, rfl⟩
    have := IsLocalizedModule.mk'_smul_mk' S f 1 x t 1
    simp only [IsLocalizedModule.mk'_one, one_smul, mul_one] at this
    rw [← this]
    apply Submodule.smul_mem
    rw [← Submodule.restrictScalars_mem R, ← Submodule.mem_comap]
    refine (show span R s ≤ _ from ?_) hx
    rw [← Submodule.map_le_iff_le_comap, Submodule.map_span]
    exact span_le_restrictScalars _ _ _
  · rw [Submodule.span_le, Set.image_subset_iff]
    intro x hx
    exact ⟨x, subset_span hx, 1, IsLocalizedModule.mk'_one _ _ _⟩

/-- The localization map of a submodule. -/
@[simps!]
def Submodule.toLocalized' : M' →ₗ[R] M'.localized' S p f :=
  f.restrict (q := (M'.localized' S p f).restrictScalars R) (fun x hx ↦ ⟨x, hx, 1, by simp⟩)

/-- The localization map of a submodule. -/
abbrev Submodule.toLocalized : M' →ₗ[R] M'.localized p :=
  M'.toLocalized' (Localization p) p (LocalizedModule.mkLinearMap p M)

instance Submodule.isLocalizedModule : IsLocalizedModule p (M'.toLocalized' S p f) where
  map_units x := by
    simp_rw [Module.End_isUnit_iff]
    constructor
    · exact fun _ _ e ↦ Subtype.ext
        (IsLocalizedModule.smul_injective f x (congr_arg Subtype.val e))
    · rintro m
      use (IsLocalization.mk' S 1 x) • m
      rw [Module.algebraMap_end_apply, ← smul_assoc, IsLocalization.smul_mk'_one,
        IsLocalization.mk'_self', one_smul]
  surj' := by
    rintro ⟨y, x, hx, s, rfl⟩
    exact ⟨⟨⟨x, hx⟩, s⟩, by ext; simp⟩
  exists_of_eq e := by simpa [Subtype.ext_iff] using
      IsLocalizedModule.exists_of_eq (S := p) (f := f) (congr_arg Subtype.val e)

/-- The localization map of a quotient module. -/
def Submodule.toLocalizedQuotient' : M ⧸ M' →ₗ[R] N ⧸ M'.localized' S p f :=
  Submodule.mapQ M' ((M'.localized' S p f).restrictScalars R) f (fun x hx ↦ ⟨x, hx, 1, by simp⟩)

/-- The localization map of a quotient module. -/
abbrev Submodule.toLocalizedQuotient : M ⧸ M' →ₗ[R] LocalizedModule p M ⧸ M'.localized p :=
  M'.toLocalizedQuotient' (Localization p) p (LocalizedModule.mkLinearMap p M)

@[simp]
lemma Submodule.toLocalizedQuotient'_mk (x : M) :
    M'.toLocalizedQuotient' S p f (Submodule.Quotient.mk x) = Submodule.Quotient.mk (f x) := rfl

open Submodule Submodule.Quotient IsLocalization in
instance IsLocalizedModule.toLocalizedQuotient' (M' : Submodule R M) :
    IsLocalizedModule p (M'.toLocalizedQuotient' S p f) where
  map_units x := by
    refine (Module.End_isUnit_iff _).mpr ⟨fun m n e ↦ ?_, fun m ↦ ⟨(IsLocalization.mk' S 1 x) • m,
        by rw [Module.algebraMap_end_apply, ← smul_assoc, smul_mk'_one, mk'_self', one_smul]⟩⟩
    obtain ⟨⟨m, rfl⟩, n, rfl⟩ := PProd.mk (mk_surjective _ m) (mk_surjective _ n)
    simp only [Module.algebraMap_end_apply, ← mk_smul, Submodule.Quotient.eq, ← smul_sub] at e
    replace e := Submodule.smul_mem _ (IsLocalization.mk' S 1 x) e
    rwa [smul_comm, ← smul_assoc, smul_mk'_one, mk'_self', one_smul, ← Submodule.Quotient.eq] at e
  surj' y := by
    obtain ⟨y, rfl⟩ := mk_surjective _ y
    obtain ⟨⟨y, s⟩, rfl⟩ := IsLocalizedModule.mk'_surjective p f y
    exact ⟨⟨Submodule.Quotient.mk y, s⟩,
      by simp only [Function.uncurry_apply_pair, toLocalizedQuotient'_mk, ← mk_smul, mk'_cancel']⟩
  exists_of_eq {m n} e := by
    obtain ⟨⟨m, rfl⟩, n, rfl⟩ := PProd.mk (mk_surjective _ m) (mk_surjective _ n)
    obtain ⟨x, hx, s, hs⟩ : f (m - n) ∈ _ := by simpa [Submodule.Quotient.eq] using e
    obtain ⟨c, hc⟩ := exists_of_eq (S := p) (show f (s • (m - n)) = f x by simp [-map_sub, ← hs])
    exact ⟨c * s, by simpa only [← Quotient.mk_smul, Submodule.Quotient.eq,
      ← smul_sub, mul_smul, hc] using M'.smul_mem c hx⟩

instance (M' : Submodule R M) : IsLocalizedModule p (M'.toLocalizedQuotient p) :=
  IsLocalizedModule.toLocalizedQuotient' _ _ _ _

section LinearMap

variable {P : Type w} [AddCommGroup P] [Module R P]
variable {Q : Type w'} [AddCommGroup Q] [Module R Q] [Module S Q] [IsScalarTower R S Q]
variable (f' : P →ₗ[R] Q) [IsLocalizedModule p f']

lemma LinearMap.localized'_ker_eq_ker_localizedMap (g : M →ₗ[R] P) :
    Submodule.localized' S p f (LinearMap.ker g) =
      LinearMap.ker ((IsLocalizedModule.map p f f' g).extendScalarsOfIsLocalization p S) := by
  ext x
  simp only [Submodule.mem_localized', mem_ker, extendScalarsOfIsLocalization_apply']
  constructor
  · rintro ⟨m, hm, a, ha, rfl⟩
    rw [IsLocalizedModule.map_mk', hm]
    simp
  · intro h
    obtain ⟨⟨a, b⟩, rfl⟩ := IsLocalizedModule.mk'_surjective p f x
    simp only [Function.uncurry_apply_pair, IsLocalizedModule.map_mk',
      IsLocalizedModule.mk'_eq_zero, IsLocalizedModule.eq_zero_iff p f'] at h
    obtain ⟨c, hc⟩ := h
    refine ⟨c • a, by simpa, c * b, by simp⟩

lemma LinearMap.ker_localizedMap_eq_localized'_ker (g : M →ₗ[R] P) :
    LinearMap.ker (IsLocalizedModule.map p f f' g) =
      ((LinearMap.ker g).localized' S p f).restrictScalars _ := by
  ext
  simp [localized'_ker_eq_ker_localizedMap S p f f']

/--
The canonical map from the kernel of `g` to the kernel of `g` localized at a submonoid.

This is a localization map by `LinearMap.toKerLocalized_isLocalizedModule`.
-/
@[simps!]
noncomputable def LinearMap.toKerIsLocalized (g : M →ₗ[R] P) :
    ker g →ₗ[R] ker (IsLocalizedModule.map p f f' g) :=
  f.restrict (fun x hx ↦ by simp [LinearMap.mem_ker, LinearMap.mem_ker.mp hx])

include S in
/-- The canonical map to the kernel of the localization of `g` is localizing.
In other words, localization commutes with kernels. -/
lemma LinearMap.toKerLocalized_isLocalizedModule (g : M →ₗ[R] P) :
    IsLocalizedModule p (toKerIsLocalized p f f' g) :=
  let e : Submodule.localized' S p f (ker g) ≃ₗ[S]
      ker ((IsLocalizedModule.map p f f' g).extendScalarsOfIsLocalization p S) :=
    LinearEquiv.ofEq _ _ (localized'_ker_eq_ker_localizedMap S p f f' g)
  IsLocalizedModule.of_linearEquiv p (Submodule.toLocalized' S p f (ker g)) (e.restrictScalars R)

end LinearMap
